//
//  SuiJsonValue.swift
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
import SwiftyJSON

/// Represents various types of JSON values used in the Sui framework.
public indirect enum SuiJsonValue: KeyProtocol, Equatable {
    /// Represents a boolean value.
    case boolean(Bool)

    /// Represents a number as UInt64.
    case number(UInt64)

    case uint16Number(UInt16)

    case uint8Number(UInt8)

    /// Represents a string value.
    case string(String)

    /// Represents a call argument, likely to be used in a function or method call.
    case callArg(Input)

    /// Represents an array of `SuiJsonValue`.
    case array([SuiJsonValue])

    /// Represents an account address.
    case address(AccountAddress)

    case input(TransactionObjectArgument)

    public var isObject: Bool {
        switch self {
        case .callArg, .address, .input:
            return true
        default:
            return false
        }
    }

    /// Provides the specific type of the JSON value.
    public var kind: SuiJsonValueType {
        switch self {
        case .boolean:
            return .boolean
        case .number:
            return .number
        case .string:
            return .string
        case .callArg:
            return .callArg
        case .array:
            return .array
        case .address:
            return .address
        case .input:
            return .input
        case .uint16Number:
            return .uint16Number
        case .uint8Number:
            return .uint8Number
        }
    }

    /// Overloads the equality operator to compare two SuiJsonValue instances.
    public static func == (lhs: SuiJsonValue, rhs: SuiJsonValue) -> Bool {
        let ser1 = Serializer()
        let ser2 = Serializer()

        do {
            try Serializer._struct(ser1, value: lhs)
            try Serializer._struct(ser2, value: rhs)

            return ser1.output() == ser2.output()
        } catch {
            return false
        }
    }

    /// Constructs a `SuiJsonValue` from a JSON object.
    public static func fromJSON(_ input: JSON) -> SuiJsonValue? {
        if let bool = input.bool {
            return .boolean(bool)
        }
        if let number = input.int {
            return .number(UInt64(number))
        }
        if let string = input.string {
            if let account: AccountAddress = try? AccountAddress.fromHex(string) {
                return .address(account)
            }
            return .string(string)
        }
        if let callArg = Input(input: input) {
            return .callArg(callArg)
        }
        if let array = input.array {
            return .array(array.compactMap { SuiJsonValue.fromJSON($0) })
        }
        return nil
    }

    public func toData() throws -> Data {
        let ser = Serializer()
        try self.serialize(ser)
        return ser.output()
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .boolean(let bool):
            try Serializer.bool(serializer, bool)
        case .number(let uint64):
            try Serializer.u64(serializer, uint64)
        case .string(let string):
            try Serializer.str(serializer, string)
        case .callArg(let callArg):
            try Serializer._struct(serializer, value: callArg)
        case .array(let array):
            try serializer.sequence(array, Serializer._struct)
        case .address(let account):
            try Serializer._struct(serializer, value: account)
        case .input(let input):
            try Serializer._struct(serializer, value: input)
        case .uint16Number(let uint16):
            try Serializer.u16(serializer, uint16)
        case .uint8Number(let uint8):
            try Serializer.u8(serializer, uint8)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiJsonValue {
        if let account: AccountAddress = try? Deserializer._struct(deserializer) {
            return .address(account)
        }
        if let bool = try? deserializer.bool() {
            return .boolean(bool)
        }
        if let uint8Number = try? Deserializer.u8(deserializer) {
            return .uint8Number(uint8Number)
        }
        if let uint16Number = try? Deserializer.u16(deserializer) {
            return .uint16Number(uint16Number)
        }
        if let number = try? Deserializer.u64(deserializer) {
            return .number(number)
        }
        if let string = try? Deserializer.string(deserializer) {
            return .string(string)
        }
        if let callArg: Input = try? Deserializer._struct(deserializer) {
            return .callArg(callArg)
        }
        if let array: [SuiJsonValue] = try? deserializer.sequence(valueDecoder: Deserializer._struct) {
            return .array(array)
        }
        if let input: TransactionObjectArgument = try? Deserializer._struct(deserializer) {
            return .input(input)
        }
        throw SuiError.customError(message: "Unable to Deserialize")
    }
}
