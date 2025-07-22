//
//  Serializer.swift
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

/// A highly optimized BCS (Binary Canonical Serialization) Serializer
/// Based on the reference Rust implementation with zero-copy optimizations
public final class Serializer {

    // MARK: - Constants
    private static let MAX_SEQUENCE_LENGTH: UInt32 = (1 << 31) - 1
    private static let MAX_CONTAINER_DEPTH = 500
    private static let INITIAL_CAPACITY = 1024

    // MARK: - Properties
    private var buffer: UnsafeMutableRawBufferPointer
    private var capacity: Int
    private var count: Int = 0
    private var containerDepth: Int = 0

    // MARK: - Initialization
    public init() {
        self.capacity = Self.INITIAL_CAPACITY
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: capacity, alignment: 1)
    }

    public init(capacity: Int) {
        self.capacity = capacity
        self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: capacity, alignment: 1)
    }

    deinit {
        buffer.deallocate()
    }

    /// Reset the serializer for reuse
    public func reset() {
        count = 0
        containerDepth = 0
    }

    /// Get the serialized data
    public func output() -> Data {
        return Data(bytes: buffer.baseAddress!, count: count)
    }

    // MARK: - Buffer Management

    private func ensureCapacity(_ needed: Int) {
        guard count + needed > capacity else { return }

        let newCapacity = Swift.max(capacity * 2, count + needed)
        let newBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: newCapacity, alignment: 1)

        // Copy existing data
        newBuffer.copyMemory(from: UnsafeRawBufferPointer(rebasing: buffer.prefix(count)))

        // Update properties
        buffer.deallocate()
        buffer = newBuffer
        capacity = newCapacity
    }

    @inline(__always)
    private func writeBytes(_ bytes: UnsafeRawBufferPointer) {
        ensureCapacity(bytes.count)
        // get the base raw pointer, advance by our current 'count',
        // then copy 'bytes.count' bytes from the source buffer
        buffer.baseAddress!                                          // UnsafeMutableRawPointer
            .advanced(by: count)                                  // offset into buffer :contentReference[oaicite:0]{index=0}
            .copyMemory(from: bytes.baseAddress!,                  // UnsafeRawPointer
                        byteCount: bytes.count)                   // copy exactly 'bytes.count' bytes :contentReference[oaicite:1]{index=1}
        count += bytes.count
    }

    @inline(__always)
    private func writeByte(_ byte: UInt8) {
        ensureCapacity(1)
        buffer.storeBytes(of: byte, toByteOffset: count, as: UInt8.self)
        count += 1
    }

    // MARK: - Primitive Serialization (Optimized)

    private func serializeBool(_ value: Bool) {
        writeByte(value ? 1 : 0)
    }

    private func serializeU8(_ value: UInt8) {
        writeByte(value)
    }

    private func serializeU16(_ value: UInt16) {
        let littleEndian = value.littleEndian
        withUnsafeBytes(of: littleEndian) { bytes in
            writeBytes(bytes)
        }
    }

    private func serializeU32(_ value: UInt32) {
        let littleEndian = value.littleEndian
        withUnsafeBytes(of: littleEndian) { bytes in
            writeBytes(bytes)
        }
    }

    private func serializeU64(_ value: UInt64) {
        let littleEndian = value.littleEndian
        withUnsafeBytes(of: littleEndian) { bytes in
            writeBytes(bytes)
        }
    }

    private func serializeU128(_ value: UInt128) {
        let littleEndian = value.littleEndian
        withUnsafeBytes(of: littleEndian) { bytes in
            writeBytes(bytes)
        }
    }

    private func serializeU256(_ value: UInt256) {
        let littleEndian = value.littleEndian
        withUnsafeBytes(of: littleEndian) { bytes in
            writeBytes(bytes)
        }
    }

    private func serializeString(_ string: String) throws {
        // Use UTF-8 view for direct byte access
        let utf8 = string.utf8
        try serializeULEB128(UInt32(utf8.count))

        // Write UTF-8 bytes directly
        utf8.withContiguousStorageIfAvailable { bytes in
            writeBytes(UnsafeRawBufferPointer(bytes))
        } ?? {
            // Fallback for non-contiguous storage
            let data = Data(string.utf8)
            data.withUnsafeBytes { bytes in
                writeBytes(bytes)
            }
        }()
    }

    private func serializeData(_ data: Data) throws {
        try serializeULEB128(UInt32(data.count))
        data.withUnsafeBytes { bytes in
            writeBytes(bytes)
        }
    }

    // MARK: - ULEB128 Encoding (Optimized)

    private func serializeULEB128(_ value: UInt32) throws {
        guard value <= Self.MAX_SEQUENCE_LENGTH else {
            throw BCSError.invalidSequenceLength(value)
        }

        var remaining = value
        while remaining >= 0x80 {
            writeByte(UInt8(remaining & 0x7F) | 0x80)
            remaining >>= 7
        }
        writeByte(UInt8(remaining & 0x7F))
    }

    // MARK: - Legacy API Compatibility Layer

    /// Serialize a boolean value or an array of boolean values using a custom Serializer.
    public static func bool<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let boolValue = value as? Bool {
            serializer.serializeBool(boolValue)
        } else if let boolArray = value as? [Bool] {
            try serializer.sequence(boolArray, Serializer.bool)
        } else {
            throw BCSError.invalidDataValue(supportedType: "Bool or [Bool]")
        }
    }

    /// Convert a Data value or an array of Data values into bytes using a custom Serializer.
    static func toBytes<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let dataValue = value as? Data {
            try serializer.serializeData(dataValue)
        } else if let dataArray = value as? [Data] {
            try serializer.sequence(dataArray, Serializer.toBytes)
        } else {
            throw BCSError.invalidDataValue(supportedType: "Data or [Data]")
        }
    }

    /// Appends a data value to the output buffer.
    func fixedBytes(_ value: Data) {
        value.withUnsafeBytes { bytes in
            writeBytes(bytes)
        }
    }

    /// Serialize a value conforming to the EncodingProtocol using a custom Serializer.
    public static func _struct(_ serializer: Serializer, value: EncodingProtocol) throws {
        if let keyProtocolValue = value as? KeyProtocol {
            try keyProtocolValue.serialize(serializer)
        } else {
            throw BCSError.doesNotConformTo(protocolType: "KeyProtocol")
        }
    }

    /// Encode a dictionary with custom key and value encoders and serialize the encoded data.
    func map<T, U>(
        _ values: [T: U],
        keyEncoder: (Serializer, T) throws -> Void,
        valueEncoder: (Serializer, U) throws -> Void
    ) throws {
        var encodedValues: [(Data, Data)] = []
        for (key, value) in values {
            do {
                let keyData = try encoder(key, keyEncoder)
                let valueData = try encoder(value, valueEncoder)
                encodedValues.append((keyData, valueData))
            } catch {
                continue
            }
        }

        // Sort by lexicographical order of serialized keys
        encodedValues.sort { lhs, rhs in
            lhs.0.lexicographicallyPrecedes(rhs.0)
        }

        // Remove duplicates (keep first occurrence)
        var uniqueValues: [(Data, Data)] = []
        var lastKey: Data?

        for (keyData, valueData) in encodedValues {
            if lastKey != keyData {
                uniqueValues.append((keyData, valueData))
                lastKey = keyData
            }
        }

        try serializeULEB128(UInt32(uniqueValues.count))
        for (keyData, valueData) in uniqueValues {
            fixedBytes(keyData)
            fixedBytes(valueData)
        }
    }

    /// Create a closure for serializing a sequence of values using a custom value encoder and Serializer.
    static func sequenceSerializer<T>(
        _ valueEncoder: @escaping (Serializer, T) throws -> Void
    ) -> (Serializer, [T]) throws -> Void {
        return { (self, values) in try self.sequence(values, valueEncoder) }
    }

    /// Serialize a sequence of values using a custom value encoder.
    public func sequence<T>(
        _ values: [T],
        _ valueEncoder: (Serializer, T) throws -> Void
    ) throws {
        try serializeULEB128(UInt32(values.count))
        for value in values {
            do {
                let bytes = try encoder(value, valueEncoder)
                fixedBytes(bytes)
            } catch {
                continue
            }
        }
    }

    public func optionalSequence<T: EncodingProtocol>(
        _ values: [T?],
        _ valueEncoder: (Serializer, T) throws -> Void
    ) throws {
        try serializeULEB128(UInt32(values.count))
        for value in values {
            do {
                try self._optional(value, valueEncoder)
            } catch {
                continue
            }
        }
    }

    /// Serialize a String value or an array of String values using a custom Serializer.
    public static func str<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let str = value as? String {
            try serializer.serializeString(str)
        } else if let strArray = value as? [String] {
            try serializer.sequence(strArray, Serializer.str)
        } else {
            throw BCSError.invalidDataValue(supportedType: "String or [String]")
        }
    }

    /// Serialize a UInt8 value or an array of UInt8 values using a custom Serializer.
    public static func u8<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint8 = value as? UInt8 {
            serializer.serializeU8(uint8)
        } else if let uint8Array = value as? [UInt8] {
            try serializer.sequence(uint8Array, Serializer.u8)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt8 or [UInt8]")
        }
    }

    /// Serialize a UInt16 value or an array of UInt16 values using a custom Serializer.
    public static func u16<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint16 = value as? UInt16 {
            serializer.serializeU16(uint16)
        } else if let uint16Array = value as? [UInt16] {
            try serializer.sequence(uint16Array, Serializer.u16)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt16 or [UInt16]")
        }
    }

    /// Serialize a UInt32 value or an array of UInt32 values using a custom Serializer.
    public static func u32<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint32 = value as? UInt32 {
            serializer.serializeU32(uint32)
        } else if let uint32Array = value as? [UInt32] {
            try serializer.sequence(uint32Array, Serializer.u32)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt32 or [UInt32]")
        }
    }

    /// Serialize a UInt64 value or an array of UInt64 values using a custom Serializer.
    public static func u64<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint64 = value as? UInt64 {
            serializer.serializeU64(uint64)
        } else if let uint64Array = value as? [UInt64] {
            try serializer.sequence(uint64Array, Serializer.u64)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt64 or [UInt64]")
        }
    }

    /// Serialize a UInt128 value or an array of UInt128 values using a custom Serializer.
    public static func u128<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint128 = value as? UInt128 {
            serializer.serializeU128(uint128)
        } else if let uint128Array = value as? [UInt128] {
            try serializer.sequence(uint128Array, Serializer.u128)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt128 or [UInt128]")
        }
    }

    /// Serialize a UInt256 value or an array of UInt256 values using a custom Serializer.
    public static func u256<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint256 = value as? UInt256 {
            serializer.serializeU256(uint256)
        } else if let uint256Array = value as? [UInt256] {
            try serializer.sequence(uint256Array, Serializer.u256)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt256 or [UInt256]")
        }
    }

    public func _optional<T: EncodingContainer>(
        _ value: T?,
        _ valueEncoder: (Serializer, T) throws -> Void
    ) throws {
        if let value = value {
            writeByte(1)
            let bytes = try encoder(value, valueEncoder)
            fixedBytes(bytes)
        } else {
            writeByte(0)
        }
    }

    /// Serialize a given UInt value as a ULEB128 encoded integer.
    func uleb128(_ value: UInt) throws {
        try serializeULEB128(UInt32(value))
    }

    /// Write an unsigned integer value to the Serializer's output data buffer.
    private func writeInt(_ value: any UnsignedInteger, length: Int) {
        var _value = value
        let valueData = withUnsafeBytes(of: &_value) { Data($0) }
        valueData.prefix(length).withUnsafeBytes { bytes in
            writeBytes(bytes)
        }
    }

    private static func containsNonASCIICharacters(_ string: String) -> Bool {
        for scalar in string.unicodeScalars {
            if scalar.value > 127 {
                return true
            }
        }
        return false
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

// MARK: - Thread-Safe Serializer Pool

public final class SerializerPool {
    private let queue = DispatchQueue(label: "bcs.serializer.pool", qos: .userInteractive)
    private var pool: [Serializer] = []
    private let maxPoolSize = 10

    public static let shared = SerializerPool()

    private init() {}

    public func withSerializer<T>(_ operation: (Serializer) throws -> T) rethrows -> T {
        let serializer = queue.sync { () -> Serializer in
            if let serializer = pool.popLast() {
                serializer.reset()
                return serializer
            }
            return Serializer()
        }

        defer {
            queue.sync {
                if pool.count < maxPoolSize {
                    pool.append(serializer)
                }
            }
        }

        return try operation(serializer)
    }
}

/// Encode a value using a given encoding function and return the serialized data.
/// Uses a pooled serializer for better performance.
func encoder<T>(
    _ value: T,
    _ encoder: (Serializer, T) throws -> Void
) throws -> Data {
    return try SerializerPool.shared.withSerializer { serializer in
        try encoder(serializer, value)
        return serializer.output()
    }
}

// MARK: - Data Comparison Optimization

func < (lhs: Data, rhs: Data) -> Bool {
    // Much more efficient comparison using lexicographical comparison
    let lhsBytes = lhs.withUnsafeBytes { Array($0) }
    let rhsBytes = rhs.withUnsafeBytes { Array($0) }
    return lhsBytes.lexicographicallyPrecedes(rhsBytes)
}

// MARK: - Error Types

extension BCSError {
    static func invalidSequenceLength(_ length: UInt32) -> BCSError {
        return .customError("Sequence length \(length) exceeds maximum allowed")
    }

    static let exceedsMaxContainerDepth = BCSError.customError("Container depth exceeds maximum allowed")
}
