//
//  SuiJsonValue.swift
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
import SwiftyJSON

public indirect enum SuiJsonValue: KeyProtocol, Equatable {
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

    case boolean(Bool)
    case number(UInt64)
    case string(String)
    case callArg(Input)
    case array([SuiJsonValue])
    case address(AccountAddress)

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
        }
    }

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
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiJsonValue {
        if let account: AccountAddress = try? Deserializer._struct(deserializer) {
            return .address(account)
        }
        if let bool = try? deserializer.bool() {
            return .boolean(bool)
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
        throw SuiError.unableToDeserialize
    }
}
