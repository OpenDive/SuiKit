//
//  Serializer.swift
//  SuiKit
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

/// A BCS (Binary Canonical Serialization) Serializer meant for serializing data
public class Serializer {
    /// The outputted data itself
    private var _output: Data

    init() {
        self._output = Data()
    }

    /// Returns the `_output` object.
    /// - Returns: `Data` object.
    func output() -> Data {
        return self._output
    }

    /// Serialize a boolean value or an array of boolean values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single boolean or an array of booleans. The serialized boolean
    /// value is represented as UInt8 where true is encoded as 1 and false is encoded as 0.
    ///
    /// - Parameters:
    ///   - serializer: A custom Serializer instance to be used for serialization.
    ///   - value: A generic value conforming to EncodingContainer, which is either a Bool or an array of Bools.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either `Bool` or `[Bool]`,
    /// if the provided value does not match either a Bool or an array of Bools.
    public static func bool<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let boolValue = value as? Bool {
            let result: UInt8 = boolValue ? UInt8(1) : UInt8(0)
            serializer.writeInt(result, length: 1)
        } else if let boolArray = value as? [Bool] {
            try serializer.sequence(boolArray, Serializer.bool)
        } else {
            throw BCSError.invalidDataValue(supportedType: "Bool or [Bool]")
        }
    }

    /// Convert a Data value or an array of Data values into bytes using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to convert the value as a single Data object or an array of Data objects into bytes. The
    /// bytes are appended to the Serializer's output buffer.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for converting data into bytes.
    ///    - value: A generic value conforming to EncodingContainer, which is either a Data object or an array of Data objects.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either Data or [Data],
    /// if the provided value does not match either a Data object or an array of Data objects.
    static func toBytes<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let dataValue = value as? Data {
            try serializer.uleb128(UInt(dataValue.count))
            serializer._output.append(dataValue)
        } else if let dataArray = value as? [Data] {
            try serializer.sequence(dataArray, Serializer.toBytes)
        } else {
            throw BCSError.invalidDataValue(supportedType: "Data or [Data]")
        }
    }

    /// Appends a data value to the `_output` private object.
    /// - Parameter value: the value itself.
    func fixedBytes(_ value: Data) {
        self._output.append(value)
    }

    /// Serialize a value conforming to the EncodingProtocol using a custom Serializer, ensuring it conforms to the KeyProtocol.
    ///
    /// This function takes a custom Serializer and a value conforming to the EncodingProtocol, and attempts to
    /// serialize the value by calling its serialize method. The value must also conform to the KeyProtocol.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A value conforming to EncodingProtocol and expected to conform to KeyProtocol.
    ///
    /// - Throws: An SuiError object with a message that the value does not conform to the required KeyProtocol,
    /// if the provided value does not conform to KeyProtocol.
    public static func _struct(_ serializer: Serializer, value: EncodingProtocol) throws {
        if let keyProtocolValue = value as? KeyProtocol {
            try keyProtocolValue.serialize(serializer)
        } else {
            throw BCSError.doesNotConformTo(protocolType: "KeyProtocol")
        }
    }

    /// Encode a dictionary with custom key and value encoders and serialize the encoded data using a custom Serializer.
    ///
    /// This function takes a dictionary with keys of type T and values of type U, along with custom key and value
    /// encoders. It encodes the dictionary entries using the provided encoders, sorts them by the encoded keys, and
    /// serializes the encoded key-value pairs using a custom Serializer instance.
    ///
    /// - Parameters:
    ///    - values: A dictionary with keys of type T and values of type U to be encoded and serialized.
    ///    - keyEncoder: A closure that accepts a Serializer and a key of type T, and throws an error if the key cannot be encoded.
    ///    - valueEncoder: A closure that accepts a Serializer and a value of type U, and throws an error if the value cannot be encoded.
    ///
    /// - Throws: This function may throw an error from the keyEncoder or valueEncoder closures when encoding a key or value fails.
    func map<T, U>(
        _ values: [T: U],
        keyEncoder: (Serializer, T) throws -> (),
        valueEncoder: (Serializer, U) throws -> ()
    ) throws {
        var encodedValues: [(Data, Data)] = []
        for (key, value) in values {
            do {
                let key = try encoder(key, keyEncoder)
                let value = try encoder(value, valueEncoder)
                encodedValues.append((key, value))
            } catch {
                continue
            }
        }
        encodedValues.sort(by: { $0.0 < $1.0 })

        try self.uleb128(UInt(encodedValues.count))
        for (key, value) in encodedValues {
            self.fixedBytes(key)
            self.fixedBytes(value)
        }
    }

    /// Create a closure for serializing a sequence of values using a custom value encoder and Serializer.
    ///
    /// This function takes a custom value encoder closure and returns a closure that accepts a Serializer instance
    /// and an array of values of type T. The returned closure serializes the given sequence using the provided
    /// value encoder and Serializer instance.
    ///
    /// - Parameter valueEncoder: A closure that accepts a Serializer and a value of type T, and throws an error
    /// if the value cannot be encoded.
    ///
    /// - Returns: A closure that accepts a Serializer instance and an array of values of type T, and throws an error
    /// if the sequence cannot be serialized using the provided value encoder.
    static func sequenceSerializer<T>(
        _ valueEncoder: @escaping (Serializer, T) throws -> ()
    ) -> (Serializer, [T]) throws -> Void {
        return { (self, values) in try self.sequence(values, valueEncoder) }
    }

    /// Serialize a sequence of values using a custom value encoder and the current Serializer instance.
    ///
    /// This function takes an array of values of type T and a custom value encoder closure. It serializes the
    /// given sequence using the provided value encoder and the current Serializer instance.
    ///
    /// - Parameters:
    ///    - values: An array of values of type T to be serialized.
    ///    - valueEncoder: A closure that accepts a Serializer and a value of type T, and throws an error if the
    /// value cannot be encoded.
    ///
    /// - Throws: This function may throw an error from the valueEncoder closure when encoding a value fails.
    public func sequence<T>(
        _ values: [T],
        _ valueEncoder: (Serializer, T) throws -> ()
    ) throws {
        try self.uleb128(UInt(values.count))
        for value in values {
            do {
                let bytes = try encoder(value, valueEncoder)
                self.fixedBytes(bytes)
            } catch {
                continue
            }
        }
    }

    public func optionalSequence<T: EncodingProtocol>(
        _ values: [T?],
        _ valueEncoder: (Serializer, T) throws -> ()
    ) throws {
        try self.uleb128(UInt(values.count))
        for value in values {
            do {
                try self._optional(value, valueEncoder)
            } catch {
                continue
            }
        }
    }

    /// Serialize a String value or an array of String values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single String or an array of Strings. The serialized String
    /// values are converted to Data using UTF-8 encoding.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a String or an array of Strings.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either String or [String],
    /// if the provided value does not match either a String object or an array of String objects.
    public static func str<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let str = value as? String {
            if Self.containsNonASCIICharacters(str) {
                try Serializer.toBytes(serializer, Data(str.utf8))
            } else {
                try Serializer.toBytes(serializer, str.data(using: .ascii)!)
            }
        } else if let strArray = value as? [String] {
            try serializer.sequence(strArray, Serializer.str)
        } else {
            throw BCSError.invalidDataValue(supportedType: "String or [String]")
        }
    }

    /// Serialize a UInt8 value or an array of UInt8 values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single UInt8 or an array of UInt8s.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a UInt8 or an array of UInt8s.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either UInt8 or [UInt8],
    /// if the provided value does not match either a UInt8 object or an array of UInt8 objects.
    public static func u8<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint8 = value as? UInt8 {
            serializer.writeInt(UInt8(uint8), length: 1)
        } else if let uint8Array = value as? [UInt8] {
            try serializer.sequence(uint8Array, Serializer.u8)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt8 or [UInt8]")
        }
    }

    /// Serialize a UInt16 value or an array of UInt16 values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single UInt16 or an array of UInt16s.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a UInt16 or an array of UInt16s.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either UInt16 or [UInt16],
    /// if the provided value does not match either a UInt16 or an array of UInt16s.
    public static func u16<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint16 = value as? UInt16 {
            serializer.writeInt(UInt16(uint16), length: 2)
        } else if let uint16Array = value as? [UInt16] {
            try serializer.sequence(uint16Array, Serializer.u16)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt16 or [UInt16]")
        }
    }

    /// Serialize a UInt32 value or an array of UInt32 values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single UInt32 or an array of UInt32s.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a UInt32 or an array of UInt32s.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either UInt32 or [UInt32],
    /// if the provided value does not match either a UInt32 or an array of UInt32s.
    public static func u32<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint32 = value as? UInt32 {
            serializer.writeInt(UInt32(uint32), length: 4)
        } else if let uint32Array = value as? [UInt32] {
            try serializer.sequence(uint32Array, Serializer.u32)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt32 or [UInt32]")
        }
    }

    /// Serialize a UInt64 value or an array of UInt64 values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single UInt64 or an array of UInt64s.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a UInt64 or an array of UInt64s.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either UInt64 or [UInt64],
    /// if the provided value does not match either a UInt64 or an array of UInt64s.
    public static func u64<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint64 = value as? UInt64 {
            serializer.writeInt(UInt64(uint64), length: 8)
        } else if let uint64Array = value as? [UInt64] {
            try serializer.sequence(uint64Array, Serializer.u64)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt64 or [UInt64]")
        }
    }

    /// Serialize a UInt128 value or an array of UInt128 values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single UInt128 or an array of UInt128s.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a UInt128 or an array of UInt128s.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either UInt128 or [UInt128],
    /// if the provided value does not match either a UInt128 or an array of UInt128s.
    public static func u128<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint128 = value as? UInt128 {
            serializer.writeInt(UInt128(uint128), length: 16)
        } else if let uint128Array = value as? [UInt128] {
            try serializer.sequence(uint128Array, Serializer.u128)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt128 or [UInt128]")
        }
    }

    /// Serialize a UInt256 value or an array of UInt256 values using a custom Serializer.
    ///
    /// This function takes a custom Serializer and a generic value conforming to the EncodingContainer protocol,
    /// and attempts to serialize the value as a single UInt256 or an array of UInt256s.
    ///
    /// - Parameters:
    ///    - serializer: A custom Serializer instance to be used for serialization.
    ///    - value: A generic value conforming to EncodingContainer, which is either a UInt256 or an array of UInt256s.
    ///
    /// - Throws: An SuiError object that's an invalid data value with the supported type of either UInt256 or [UInt256],
    /// if the provided value does not match either a UInt256 or an array of UInt256s.
    public static func u256<T: EncodingContainer>(_ serializer: Serializer, _ value: T) throws {
        if let uint256 = value as? UInt256 {
            serializer.writeInt(uint256, length: 32)
        } else if let uint256Array = value as? [UInt256] {
            try serializer.sequence(uint256Array, Serializer.u256)
        } else {
            throw BCSError.invalidDataValue(supportedType: "UInt256 or [UInt256]")
        }
    }

    public func _optional<T: EncodingContainer>(
        _ value: T?,
        _ valueEncoder: (Serializer, T) throws -> ()
    ) throws {
        if let value {
            let bytes = try encoder(value, valueEncoder)
            self.fixedBytes(bytes)
        } else {
            self._output.append(0)
        }
    }

    /// Serialize a given UInt value as a ULEB128 (Unsigned Little Endian Base 128) encoded integer.
    ///
    /// This function takes a UInt value and encodes it using the ULEB128 variable-length integer encoding.
    /// This encoding is efficient for representing small integers and reduces the serialized data size.
    ///
    /// - Parameter value: A UInt value to be serialized as a ULEB128 encoded integer.
    ///
    /// - Throws: An error if the Serializer.u8 function call fails while encoding the ULEB128 value.
    func uleb128(_ value: UInt) throws {
        var _value = value
        while _value >= 0x80 {
            let byte = _value & 0x7F
            try Serializer.u8(self, UInt8(byte | 0x80))
            _value >>= 7
        }
        try Serializer.u8(self, UInt8(_value & 0x7F))
    }

    /// Write an unsigned integer value to the Serializer's output data buffer.
    ///
    /// This function takes an unsigned integer value and writes the first length bytes of the value
    /// to the Serializer's output data buffer. The value is added in little-endian byte order.
    ///
    /// - Parameters:
    ///    - value: An unsigned integer value to be written to the Serializer's output data buffer.
    ///    - length: The number of bytes to write from the given unsigned integer value.
    private func writeInt(_ value: any UnsignedInteger, length: Int) {
        var _value = value
        let valueData = withUnsafeBytes(of: &_value) { Data($0) }
        self._output.append(valueData.prefix(length))
    }

    private static func containsNonASCIICharacters(_ string: String) -> Bool {
        for scalar in string.unicodeScalars {
            if scalar.value > 127 {
                return true
            }
        }
        return false
    }
}

/// Encode a value using a given encoding function and return the serialized data.
///
/// This function takes a value and an encoding function, and uses the function to encode the value
/// using a new Serializer instance. It then returns the serialized data from the Serializer's output.
///
/// - Parameters:
///    - value: The value to be encoded.
///    - encoder: The encoding function that accepts a Serializer instance and the value to be encoded.
///
/// - Returns: A Data object containing the serialized representation of the value.
///
/// - Throws: Any error that may occur during the encoding process with the given encoding function.
func encoder<T>(
    _ value: T,
    _ encoder: (Serializer, T) throws -> ()
) throws -> Data {
    let ser = Serializer()
    try encoder(ser, value)
    return ser.output()
}

func < (lhs: Data, rhs: Data) -> Bool {
    let lhsString = lhs.reduce("", { $0 + String(format: "%02x", $1) })
    let rhsString = rhs.reduce("", { $0 + String(format: "%02x", $1) })
    return lhsString < rhsString
}
