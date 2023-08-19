//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum SuiJsonValueType: String {
    case boolean = "Boolean"
    case number = "Number"
    case string = "String"
    case callArg = "CallArg"
    case array = "Array"
    case address = "Address"
}

public indirect enum SuiJsonValue: KeyProtocol {
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
        throw SuiError.notImplemented
    }
}
