//
//  Deserializer.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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

/// A BCS (Binary Canonical Serialization) Deserializer meant for Deserializing data
public class Deserializer {
    /// The input data itself
    private var input: Data

    /// Meant for determining how many bytes are left to deserialize
    private var position: Int = 0

    public init(data: Data) {
        self.input = data
    }

    /// Calculate the remaining number of bytes in the input data buffer.
    ///
    /// This function returns the number of bytes remaining in the Serializer's input data buffer
    /// by subtracting the current position from the total count of bytes.
    ///
    /// - Returns: An Int representing the number of bytes remaining in the input data buffer.
    public func remaining() -> Int {
        return input.count - position
    }

    /// Deserialize a boolean value from the Serializer's input data buffer.
    ///
    /// This function reads an integer of length 1 byte from the input data buffer,
    /// and returns a boolean value based on its content. A value of 0 represents false
    /// and a value of 1 represents true. If the read value is not 0 or 1, it throws an error.
    ///
    /// - Returns: A Bool value deserialized from the input data buffer.
    ///
    /// - Throws: An SuiError.unexpectedValue error if the value read from the input data buffer is neither 0 nor 1.
    public func bool() throws -> Bool {
        let value = Int(try readInt(length: 1))
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            throw SuiError.unexpectedValue(value: "\(value)")
        }
    }

    /// Deserialize a Data object from the Deserializer's input data buffer.
    ///
    /// This function reads the length of the data as a ULEB128-encoded integer, followed by
    /// reading the data with the obtained length from the input data buffer.
    ///
    /// - Parameter deserializer: A Deserializer instance to deserialize the data from.
    ///
    /// - Returns: A Data object deserialized from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the ULEB128-encoded length or the data.
    public static func toBytes(_ deserializer: Deserializer) throws -> Data {
        let length = try deserializer.uleb128()
        return try deserializer.read(length: Int(length))
    }

    /// Deserialize a fixed-length Data object from the Deserializer's input data buffer.
    ///
    /// This function reads the specified number of bytes from the input data buffer
    /// and returns the data as a Data object.
    ///
    /// - Parameter length: The number of bytes to read from the input data buffer.
    ///
    /// - Returns: A Data object of the specified length deserialized from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the data.
    public func fixedBytes(length: Int) throws -> Data {
        return try read(length: length)
    }

    /// Deserialize a dictionary of key-value pairs from the Deserializer's input data buffer.
    ///
    /// This function first reads the length of the dictionary as a ULEB128-encoded integer.
    /// Then, it iteratively decodes keys and values using the provided keyDecoder and valueDecoder closures
    /// until the desired number of pairs is deserialized.
    ///
    /// - Parameters:
    ///    - keyDecoder: A closure that takes a Deserializer instance and returns a decoded key of type K.
    ///    - valueDecoder: A closure that takes a Deserializer instance and returns a decoded value of type V.
    ///
    /// - Returns: A dictionary of [K: V] deserialized from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the ULEB128-encoded length, keys, or values.
    public func map<K, V>(keyDecoder: (Deserializer) throws -> K, valueDecoder: (Deserializer) throws -> V) throws -> [K: V] {
        let length = try uleb128()
        var values: [K: V] = [:]
        while values.count < length {
            let key = try keyDecoder(self)
            let value = try valueDecoder(self)
            values[key] = value
        }
        return values
    }

    /// Deserialize a sequence of values from the Deserializer's input data buffer.
    ///
    /// This function first reads the length of the sequence as a ULEB128-encoded integer.
    /// Then, it iteratively decodes values using the provided valueDecoder closure
    /// until the desired number of elements is deserialized.
    ///
    /// - Parameter valueDecoder: A closure that takes a Deserializer instance and returns a decoded value of type T.
    ///
    /// - Returns: An array of [T] deserialized from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the ULEB128-encoded length or the values.
    public func sequence<T>(valueDecoder: (Deserializer) throws -> T) throws -> [T] {
        let length = try uleb128()
        var values: [T] = []
        while values.count < length {
            values.append(try valueDecoder(self))
        }
        return values
    }

    /// Deserialize a string from the Deserializer's input data buffer.
    ///
    /// This function first calls Deserializer.toBytes(_:) to read the raw bytes for the string.
    /// Then, it attempts to convert the bytes into a String using the UTF-8 encoding.
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the string from.
    ///
    /// - Returns: A decoded String from the input data buffer.
    ///
    /// - Throws: SuiError.stringToDataFailure if the UTF-8 decoding fails.
    public static func string(_ deserializer: Deserializer) throws -> String {
        let data = try Deserializer.toBytes(deserializer)
        guard let result = String(data: data, encoding: .utf8) else {
            throw SuiError.stringToDataFailure(value: "\(data)")
        }
        return result
    }

    /// Deserialize a structure that conforms to the KeyProtocol from the Deserializer's input data buffer.
    ///
    /// This function uses the type's deserialize(from:) method, passing the current Deserializer instance,
    /// to deserialize the structure from the input data buffer.
    ///
    /// - Parameter type: The type of the structure that conforms to KeyProtocol to be deserialized.
    ///
    /// - Returns: An instance of type T deserialized from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data or decoding the structure.
    public func _struct<T: KeyProtocol>(type: T.Type) throws -> T {
        return try T.deserialize(from: self)
    }

    /// Deserialize a UInt8 value from the Deserializer's input data buffer.
    ///
    /// This function reads an 8-bit unsigned integer from the input data buffer by calling Deserializer.readInt(length:).
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the UInt8 value from.
    ///
    /// - Returns: A deserialized UInt8 value from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data.
    public static func u8(_ deserializer: Deserializer) throws -> UInt8 {
        return UInt8(try deserializer.readInt(length: 1))
    }

    /// Deserialize a UInt16 value from the Deserializer's input data buffer.
    ///
    /// This function reads a 16-bit unsigned integer from the input data buffer by calling Deserializer.readInt(length:).
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the UInt16 value from.
    ///
    /// - Returns: A deserialized UInt16 value from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data.
    public static func u16(_ deserializer: Deserializer) throws -> UInt16 {
        return UInt16(try deserializer.readInt(length: 2))
    }

    /// Deserialize a UInt32 value from the Deserializer's input data buffer.
    ///
    /// This function reads a 32-bit unsigned integer from the input data buffer by calling Deserializer.readInt(length:).
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the UInt32 value from.
    ///
    /// - Returns: A deserialized UInt32 value from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data.
    public static func u32(_ deserializer: Deserializer) throws -> UInt32 {
        return UInt32(try deserializer.readInt(length: 4))
    }

    /// Deserialize a UInt64 value from the Deserializer's input data buffer.
    ///
    /// This function reads a 64-bit unsigned integer from the input data buffer by calling Deserializer.readInt(length:).
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the UInt64 value from.
    ///
    /// - Returns: A deserialized UInt64 value from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data.
    public static func u64(_ deserializer: Deserializer) throws -> UInt64 {
        return UInt64(try deserializer.readInt(length: 8))
    }

    /// Deserialize a UInt128 value from the Deserializer's input data buffer.
    ///
    /// This function reads a 128-bit unsigned integer from the input data buffer by calling Deserializer.readInt(length:).
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the UInt128 value from.
    ///
    /// - Returns: A deserialized UInt128 value from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data.
    public static func u128(_ deserializer: Deserializer) throws -> UInt128 {
        return UInt128(try deserializer.readInt(length: 16))
    }

    /// Deserialize a UInt256 value from the Deserializer's input data buffer.
    ///
    /// This function reads a 256-bit unsigned integer from the input data buffer by calling Deserializer.readInt(length:). It then attempts to convert the result into a UInt256 instance.
    ///
    /// - Parameter deserializer: The Deserializer instance to deserialize the UInt256 value from.
    ///
    /// - Returns: A deserialized UInt256 value from the input data buffer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data, or if the conversion from the deserialized value to a UInt256 instance fails.
    public static func u256(_ deserializer: Deserializer) throws -> UInt256 {
        let value = try deserializer.readInt(length: 32)
        guard let result = UInt256(String(value)) else {
            throw SuiError.stringToUInt256Failure(value: String(value))
        }
        return result
    }

    /// Deserialize an unsigned LEB128-encoded integer from the Deserializer's input data buffer.
    ///
    /// This function reads bytes from the input data buffer and reconstructs the original unsigned integer using LEB128 encoding. LEB128 is a compact representation for variable-length integers, particularly for small values.
    ///
    /// - Returns: A deserialized UInt value representing the original unsigned integer.
    ///
    /// - Throws: Any error that may occur during the deserialization process, such as reading the input data, or if the deserialized value is larger than the maximum supported value (UInt128).
    public func uleb128() throws -> UInt {
        var value: UInt = 0
        var shift: UInt = 0

        while value <= UInt(MAX_U32) {
            let byte = try readInt(length: 1)
            value |= (UInt(byte) & 0x7F) << shift
            if Int(byte) & 0x80 == 0 {
                break
            }
            shift += 7
        }

        if value > UInt128(MAX_U128) {
            throw SuiError.unexpectedLargeULEB128Value(value: "\(value)")
        }

        return value
    }

    /// Reads a specified number of bytes from the input data and advances the current position by that amount.
    ///
    /// - Parameter length: The number of bytes to read from the input data.
    ///
    /// - Returns: A Data object containing the bytes that were read from the input data.
    ///
    /// - Throws: An SuiError object of type unexpectedEndOfInput if there are not enough bytes left in the input data
    /// to satisfy the requested length. The error message will contain the requested length and the remaining bytes available to read.
    private func read(length: Int) throws -> Data {
        guard position + length <= input.count else {
            throw SuiError.unexpectedEndOfInput(requested: "\(length)", found: "\(input.count - position)")
        }
        let range = position ..< position + length
        let value = input.subdata(in: range)
        position += length
        return value
    }

    /// Reads a specified number of bytes from the input data and interprets the bytes as an unsigned integer of a specified bit width.
    ///
    /// - Parameter length: The number of bytes to read from the input data. This determines the bit width of the unsigned integer that will be returned.
    ///
    /// - Returns: An unsigned integer of the specified bit width, representing the bytes that were read from the input data.
    ///
    /// - Throws: An SuiError object of type invalidLength if the specified length is not valid, i.e. not one of the supported lengths: 1, 2, 4, 8, 16 or 32 bytes.
    private func readInt(length: Int) throws -> any UnsignedInteger {
        let data = try read(length: length)

        if length == 1 {
            return data.withUnsafeBytes { $0.load(as: UInt8.self) }
        } else if length == 2 {
            return data.withUnsafeBytes { $0.load(as: UInt16.self) }
        } else if length == 4 {
            return data.withUnsafeBytes { $0.load(as: UInt32.self) }
        } else if length == 8 {
            return data.withUnsafeBytes { $0.load(as: UInt64.self) }
        } else if length == 16 {
            return data.withUnsafeBytes { $0.load(as: UInt128.self) }
        } else if length == 32 {
            return data.withUnsafeBytes { $0.load(as: UInt256.self) }
        } else {
            throw SuiError.invalidLength
        }
    }
}
