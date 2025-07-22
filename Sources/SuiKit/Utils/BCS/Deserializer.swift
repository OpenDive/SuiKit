//
//  Deserializer.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UInt256
import simd
import Accelerate

/// The max UInt8 value
let MAX_U8 = UInt8.max

/// The max UInt16 value
let MAX_U16 = UInt16.max

/// The max UInt32 value
let MAX_U32 = UInt32.max

/// The max UInt64 value
let MAX_U64 = UInt64.max

/// The max UInt128 value
let MAX_U128 = UInt128.max

/// The max UInt256 value
let MAX_U256 = UInt256.max

/// A highly optimized BCS (Binary Canonical Serialization) Deserializer
/// Based on the reference Rust implementation with zero-copy optimizations
/// Includes SIMD optimizations for Apple Silicon devices
public final class Deserializer {

    // MARK: - Constants
    private static let MAX_SEQUENCE_LENGTH: UInt32 = (1 << 31) - 1
    private static let MAX_CONTAINER_DEPTH = 500

    // SIMD optimization constants
    private static let SIMD_THRESHOLD = 64 // Minimum elements for SIMD operations
    private static let CACHE_LINE_SIZE = 64 // Apple Silicon cache line size
    private static let PREFETCH_DISTANCE = 128 // Bytes to prefetch ahead

    // MARK: - Properties
    private let buffer: UnsafeRawBufferPointer
    private var position: Int = 0
    private var containerDepth: Int = 0
    private let originalData: Data // Keep reference to prevent deallocation
    private var allocator: BCSAllocator?

    // Performance tracking for SIMD operations
    private var simdOperationsCount: Int = 0
    private var totalBytesProcessed: Int = 0
    private var cacheOptimalAccesses: Int = 0

    // MARK: - Position Management (for Deserializer compatibility)
    internal func setPosition(with newPosition: Int) {
        position = newPosition
    }

    internal func getPosition() -> Int {
        return position
    }

    // MARK: - Initialization

    public init(data: Data) {
        self.originalData = data
        self.allocator = nil
        self.buffer = data.withUnsafeBytes { bytes in
            UnsafeRawBufferPointer(bytes)
        }
    }

    /// Initialize with a custom allocator for SIMD optimization
    public init(data: Data, allocator: BCSAllocator) {
        self.originalData = data
        self.allocator = allocator
        self.buffer = data.withUnsafeBytes { bytes in
            UnsafeRawBufferPointer(bytes)
        }
    }

    public func output() -> Data {
        return originalData
    }

    /// Reset the deserializer position
    public func reset() {
        position = 0
        containerDepth = 0
    }

    /// Check if all data has been consumed
    public func isComplete() -> Bool {
        return position >= buffer.count
    }

    /// Calculate the remaining number of bytes in the input data buffer.
    public func remaining() -> Int {
        return Swift.max(0, buffer.count - position)
    }

    // MARK: - Core Reading Functions

    @inline(__always)
    private func ensureRemaining(_ count: Int) throws {
        guard position + count <= buffer.count else {
            throw BCSError.unexpectedEndOfInput(
                requested: "\(count)",
                found: "\(remaining())"
            )
        }
    }

    @inline(__always)
    private func readByte() throws -> UInt8 {
        try ensureRemaining(1)
        let byte = buffer.load(fromByteOffset: position, as: UInt8.self)
        position += 1
        return byte
    }

    @inline(__always)
    private func readBytes(_ count: Int) throws -> UnsafeRawBufferPointer {
        try ensureRemaining(count)
        let slice = UnsafeRawBufferPointer(
            start: buffer.baseAddress?.advanced(by: position),
            count: count
        )
        position += count
        return slice
    }

    // MARK: - Primitive Type Deserialization (Optimized)

    private func deserializeBool() throws -> Bool {
        let byte = try readByte()
        switch byte {
        case 0:
            return false
        case 1:
            return true
        default:
            throw BCSError.unexpectedValue(value: "\(byte)")
        }
    }

    private func deserializeU8() throws -> UInt8 {
        return try readByte()
    }

    private func deserializeU16() throws -> UInt16 {
        let bytes = try readBytes(2)
        return bytes.loadUnaligned(as: UInt16.self).littleEndian
    }

    private func deserializeU32() throws -> UInt32 {
        let bytes = try readBytes(4)
        return bytes.loadUnaligned(as: UInt32.self).littleEndian
    }

    private func deserializeU64() throws -> UInt64 {
        let bytes = try readBytes(8)
        return bytes.loadUnaligned(as: UInt64.self).littleEndian
    }

    private func deserializeU128() throws -> UInt128 {
        let bytes = try readBytes(16)
        return bytes.loadUnaligned(as: UInt128.self).littleEndian
    }

    private func deserializeU256() throws -> UInt256 {
        let bytes = try readBytes(32)
        return bytes.loadUnaligned(as: UInt256.self).littleEndian
    }

    // MARK: - ULEB128 Decoding (Optimized)

    private func deserializeULEB128() throws -> UInt32 {
        var value: UInt64 = 0
        var shift: Int = 0

        while shift < 32 {
            let byte = try readByte()
            let digit = UInt64(byte & 0x7F)
            value |= digit << shift

            // If the highest bit is 0, we're done
            if byte & 0x80 == 0 {
                // Check for canonical encoding
                if shift > 0 && digit == 0 {
                    throw BCSError.nonCanonicalULEB128
                }

                // Check for overflow
                guard value <= UInt64(UInt32.max) else {
                    throw BCSError.uleb128Overflow
                }

                return UInt32(value)
            }

            shift += 7
        }

        throw BCSError.uleb128Overflow
    }

    // MARK: - String Deserialization (Zero-Copy Optimized)

    private func deserializeString() throws -> String {
        let length = try deserializeULEB128()
        let bytes = try readBytes(Int(length))

        let string = String(
            decoding: UnsafeBufferPointer(
                start: bytes.bindMemory(to: UInt8.self).baseAddress,
                count: bytes.count
            ),
            as: UTF8.self
        )

        return string
    }

    // MARK: - Bytes Deserialization

    private func deserializeData() throws -> Data {
        let length = try deserializeULEB128()
        let bytes = try readBytes(Int(length))
        return Data(bytes)
    }

    private func deserializeFixedData(_ length: Int) throws -> Data {
        let bytes = try readBytes(length)
        return Data(bytes)
    }

    // MARK: - SIMD-Optimized Array Deserialization

    /// SIMD-optimized deserialization for arrays of UInt16 values
    public func deserializeU16Array() throws -> [UInt16] {
        let length = try deserializeULEB128()

        guard length <= Self.MAX_SEQUENCE_LENGTH else {
            throw BCSError.sequenceTooLong(Int(length))
        }

        let count = Int(length)
        guard count >= Self.SIMD_THRESHOLD else {
            // Fallback to standard deserialization for small arrays
            var result: [UInt16] = []
            result.reserveCapacity(count)
            for _ in 0..<count {
                result.append(try deserializeU16())
            }
            return result
        }

        simdOperationsCount += 1
        let bytes = try readBytes(count * 2)

        // Use SIMD for bulk endian conversion - use safe unaligned loads
        let result: [UInt16] = Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            let simdCount = (count / 8) * 8

            // Process 8 elements at a time using SIMD with safe unaligned loads
            for i in stride(from: 0, to: simdCount, by: 8) {
                let baseOffset = i * 2

                // Load 8 UInt16 values safely using unaligned loads
                let val0 = bytes.loadUnaligned(fromByteOffset: baseOffset, as: UInt16.self).littleEndian
                let val1 = bytes.loadUnaligned(fromByteOffset: baseOffset + 2, as: UInt16.self).littleEndian
                let val2 = bytes.loadUnaligned(fromByteOffset: baseOffset + 4, as: UInt16.self).littleEndian
                let val3 = bytes.loadUnaligned(fromByteOffset: baseOffset + 6, as: UInt16.self).littleEndian
                let val4 = bytes.loadUnaligned(fromByteOffset: baseOffset + 8, as: UInt16.self).littleEndian
                let val5 = bytes.loadUnaligned(fromByteOffset: baseOffset + 10, as: UInt16.self).littleEndian
                let val6 = bytes.loadUnaligned(fromByteOffset: baseOffset + 12, as: UInt16.self).littleEndian
                let val7 = bytes.loadUnaligned(fromByteOffset: baseOffset + 14, as: UInt16.self).littleEndian

                let simdValues = simd_ushort8(val0, val1, val2, val3, val4, val5, val6, val7)

                // Store SIMD results
                withUnsafeBytes(of: simdValues) { simdBytes in
                    let simdU16Ptr = simdBytes.bindMemory(to: UInt16.self)
                    for j in 0..<8 {
                        buffer[i + j] = simdU16Ptr[j]
                    }
                }
            }

            // Handle remaining elements with safe unaligned loads
            for i in simdCount..<count {
                let offset = i * 2
                buffer[i] = bytes.loadUnaligned(fromByteOffset: offset, as: UInt16.self).littleEndian
            }

            initializedCount = count
        }

        return result
    }

    /// SIMD-optimized deserialization for arrays of UInt32 values
    public func deserializeU32Array() throws -> [UInt32] {
        let length = try deserializeULEB128()
        let count = Int(length)

        guard count >= Self.SIMD_THRESHOLD else {
            var result: [UInt32] = []
            result.reserveCapacity(count)
            for _ in 0..<count {
                result.append(try deserializeU32())
            }
            return result
        }

        simdOperationsCount += 1
        let bytes = try readBytes(count * 4)

        let result: [UInt32] = Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            let simdCount = (count / 4) * 4

            // Process 4 elements at a time using SIMD with safe unaligned loads
            for i in stride(from: 0, to: simdCount, by: 4) {
                let baseOffset = i * 4

                // Load 4 UInt32 values safely using unaligned loads
                let val0 = bytes.loadUnaligned(fromByteOffset: baseOffset, as: UInt32.self).littleEndian
                let val1 = bytes.loadUnaligned(fromByteOffset: baseOffset + 4, as: UInt32.self).littleEndian
                let val2 = bytes.loadUnaligned(fromByteOffset: baseOffset + 8, as: UInt32.self).littleEndian
                let val3 = bytes.loadUnaligned(fromByteOffset: baseOffset + 12, as: UInt32.self).littleEndian

                let simdValues = simd_uint4(val0, val1, val2, val3)

                withUnsafeBytes(of: simdValues) { simdBytes in
                    let simdU32Ptr = simdBytes.bindMemory(to: UInt32.self)
                    for j in 0..<4 {
                        buffer[i + j] = simdU32Ptr[j]
                    }
                }
            }

            // Handle remaining elements with safe unaligned loads
            for i in simdCount..<count {
                let offset = i * 4
                buffer[i] = bytes.loadUnaligned(fromByteOffset: offset, as: UInt32.self).littleEndian
            }

            initializedCount = count
        }

        return result
    }

    /// SIMD-optimized deserialization for arrays of UInt64 values
    public func deserializeU64Array() throws -> [UInt64] {
        let length = try deserializeULEB128()
        let count = Int(length)

        guard count >= Self.SIMD_THRESHOLD else {
            var result: [UInt64] = []
            result.reserveCapacity(count)
            for _ in 0..<count {
                result.append(try deserializeU64())
            }
            return result
        }

        simdOperationsCount += 1
        let bytes = try readBytes(count * 8)

        let result: [UInt64] = Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            let simdCount = (count / 2) * 2

            // Process 2 elements at a time using SIMD with safe unaligned loads
            for i in stride(from: 0, to: simdCount, by: 2) {
                let baseOffset = i * 8

                // Load 2 UInt64 values safely using unaligned loads
                let val0 = bytes.loadUnaligned(fromByteOffset: baseOffset, as: UInt64.self).littleEndian
                let val1 = bytes.loadUnaligned(fromByteOffset: baseOffset + 8, as: UInt64.self).littleEndian

                let simdValues = simd_ulong2(UInt(val0), UInt(val1))

                withUnsafeBytes(of: simdValues) { simdBytes in
                    let simdU64Ptr = simdBytes.bindMemory(to: UInt64.self)
                    for j in 0..<2 {
                        buffer[i + j] = simdU64Ptr[j]
                    }
                }
            }

            // Handle remaining elements with safe unaligned loads
            for i in simdCount..<count {
                let offset = i * 8
                buffer[i] = bytes.loadUnaligned(fromByteOffset: offset, as: UInt64.self).littleEndian
            }

            initializedCount = count
        }

        return result
    }

    /// Deserialize packed boolean arrays using SIMD operations
    public func deserializeBoolArray() throws -> [Bool] {
        let length = try deserializeULEB128()
        let count = Int(length)
        
        guard count >= Self.SIMD_THRESHOLD else {
            var result: [Bool] = []
            result.reserveCapacity(count)
            for _ in 0..<count {
                result.append(try deserializeBool())
            }
            return result
        }

        simdOperationsCount += 1
        
        // Read packed bytes
        let packedByteCount = (count + 7) / 8
        let packedBytes = try readBytes(packedByteCount)
        
        let result: [Bool] = Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            packedBytes.withMemoryRebound(to: UInt8.self) { byteBuffer in
                let fullBytes = count / 8
                let remainingBits = count % 8
                
                // Process full bytes using bit manipulation
                for i in 0..<fullBytes {
                    let packedByte = byteBuffer[i]
                    for j in 0..<8 {
                        buffer[i * 8 + j] = (packedByte & (1 << j)) != 0
                    }
                }
                
                // Handle remaining bits
                if remainingBits > 0 {
                    let packedByte = byteBuffer[fullBytes]
                    for j in 0..<remainingBits {
                        buffer[fullBytes * 8 + j] = (packedByte & (1 << j)) != 0
                    }
                }
            }
            initializedCount = count
        }
        
        return result
    }

    // MARK: - Legacy API Compatibility Layer

    /// Deserialize a boolean value from the Serializer's input data buffer.
    public func bool() throws -> Bool {
        return try deserializeBool()
    }

    /// Deserialize a Data object from the Deserializer's input data buffer.
    public static func toBytes(_ deserializer: Deserializer) throws -> Data {
        return try deserializer.deserializeData()
    }

    /// Deserialize a fixed-length Data object from the Deserializer's input data buffer.
    public func fixedBytes(length: Int) throws -> Data {
        return try deserializeFixedData(length)
    }

    /// Deserialize a dictionary of key-value pairs from the Deserializer's input data buffer.
    public func map<K: Hashable, V>(
        keyDecoder: (Deserializer) throws -> K,
        valueDecoder: (Deserializer) throws -> V
    ) throws -> [K: V] {
        let length = try deserializeULEB128()

        var result: [K: V] = [:]
        result.reserveCapacity(Int(length))

        var previousKeyBytes: Data?

        for _ in 0..<length {
            // Capture the position before deserializing the key
            let keyStartPosition = position
            let key = try keyDecoder(self)
            let keyEndPosition = position

            // Extract the serialized key bytes for validation
            let keyBytes = originalData.subdata(in: keyStartPosition..<keyEndPosition)

            // Check canonical ordering
            if let prevKey = previousKeyBytes {
                if !prevKey.lexicographicallyPrecedes(keyBytes) {
                    // prevKey is either equal to or greater than keyBytes
                    throw BCSError.nonCanonicalMapOrder
                }
            }

            let value = try valueDecoder(self)

            // Check for duplicate keys
            if result[key] != nil {
                throw BCSError.duplicateMapKey
            }

            result[key] = value
            previousKeyBytes = keyBytes
        }

        return result
    }

    /// Deserialize a sequence of values from the Deserializer's input data buffer.
    public func sequence<T>(valueDecoder: (Deserializer) throws -> T) throws -> [T] {
        let length = try deserializeULEB128()

        guard length <= Self.MAX_SEQUENCE_LENGTH else {
            throw BCSError.sequenceTooLong(Int(length))
        }

        var result: [T] = []
        result.reserveCapacity(Int(length))

        for _ in 0..<length {
            result.append(try valueDecoder(self))
        }

        return result
    }

    /// Deserialize a string from the Deserializer's input data buffer.
    public static func string(_ deserializer: Deserializer) throws -> String {
        return try deserializer.deserializeString()
    }

    /// Deserialize a structure that conforms to the KeyProtocol from the Deserializer's input data buffer.
    public static func _struct<T: KeyProtocol>(_ deserializer: Deserializer) throws -> T {
        return try T.deserialize(from: deserializer)
    }

    /// Deserialize a UInt8 value from the Deserializer's input data buffer.
    public static func u8(_ deserializer: Deserializer) throws -> UInt8 {
        return try deserializer.deserializeU8()
    }

    /// Deserialize a UInt16 value from the Deserializer's input data buffer.
    public static func u16(_ deserializer: Deserializer) throws -> UInt16 {
        return try deserializer.deserializeU16()
    }

    /// Deserialize a UInt32 value from the Deserializer's input data buffer.
    public static func u32(_ deserializer: Deserializer) throws -> UInt32 {
        return try deserializer.deserializeU32()
    }

    /// Deserialize a UInt64 value from the Deserializer's input data buffer.
    public static func u64(_ deserializer: Deserializer) throws -> UInt64 {
        return try deserializer.deserializeU64()
    }

    /// Deserialize a UInt128 value from the Deserializer's input data buffer.
    public static func u128(_ deserializer: Deserializer) throws -> UInt128 {
        return try deserializer.deserializeU128()
    }

    /// Deserialize a UInt256 value from the Deserializer's input data buffer.
    public static func u256(_ deserializer: Deserializer) throws -> UInt256 {
        return try deserializer.deserializeU256()
    }

    public func _optional<T>(valueDecoder: (Deserializer) throws -> T) throws -> T? {
        let tag = try readByte()
        switch tag {
        case 0:
            return nil
        case 1:
            return try valueDecoder(self)
        default:
            throw BCSError.invalidOptionTag(tag)
        }
    }

    /// Deserialize an unsigned LEB128-encoded integer from the Deserializer's input data buffer.
    public func uleb128() throws -> UInt {
        return UInt(try deserializeULEB128())
    }

    /// Reads a specified number of bytes from the input data and advances the current position.
    private func read(length: Int) throws -> Data {
        let bytes = try readBytes(length)
        return Data(bytes)
    }

    /// Reads a specified number of bytes from the input data and interprets the bytes as an unsigned integer.
    private func readInt(length: Int) throws -> any UnsignedInteger {
        let bytes = try readBytes(length)

        switch length {
        case 1:
            return bytes.load(as: UInt8.self)
        case 2:
            return bytes.load(as: UInt16.self)
        case 4:
            return bytes.load(as: UInt32.self)
        case 8:
            return bytes.load(as: UInt64.self)
        case 16:
            return bytes.load(as: UInt128.self)
        case 32:
            return bytes.load(as: UInt256.self)
        default:
            throw BCSError.invalidLength
        }
    }

    // MARK: - Container Depth Management

    private func enterContainer() throws {
        guard containerDepth < Self.MAX_CONTAINER_DEPTH else {
            throw BCSError.exceedsMaxContainerDepth
        }
        containerDepth += 1
    }

    private func exitContainer() {
        containerDepth -= 1
    }
}

// MARK: - Additional Error Types

extension BCSError {
    static let nonCanonicalULEB128 = BCSError.customError("Non-canonical ULEB128 encoding")
    static let uleb128Overflow = BCSError.customError("ULEB128 integer overflow")

    static func invalidOptionTag(_ tag: UInt8) -> BCSError {
        return .customError("Invalid option tag: \(tag), expected 0 or 1")
    }

    static func sequenceTooLong(_ length: Int) -> BCSError {
        return .customError("Sequence too long: \(length)")
    }

    static let nonCanonicalMapOrder = BCSError.customError("Map keys not in canonical order")
    static let duplicateMapKey = BCSError.customError("Duplicate key found in map")
}
