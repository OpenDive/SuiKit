//
//  File.swift
//  
//
//  Created by Marcus Arnett on 11/17/23.
//

import Foundation

public enum TransactionObjectArgument: KeyProtocol {
    case gasCoin
    case result(Result)
    case nestedResult(NestedResult)
    case input(TransactionBlockInput)

    init?(from transactionArgument: TransactionArgument) {
        switch transactionArgument {
        case .gasCoin:
            self = .gasCoin
        case .result(let result):
            self = .result(result)
        case .nestedResult(let nestedResult):
            self = .nestedResult(nestedResult)
        case .input(let input):
            guard input.type != .pure else { return nil }
            self = .input(input)
        }
    }

    public func toTransactionArgument() -> TransactionArgument {
        switch self {
        case .gasCoin:
            return .gasCoin
        case .result(let result):
            return .result(result)
        case .nestedResult(let nestedResult):
            return .nestedResult(nestedResult)
        case .input(let input):
            return .input(input)
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .gasCoin:
            try Serializer.u8(serializer, UInt8(0))
        case .input(let transactionBlockInput):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: transactionBlockInput)
        case .result(let result):
            try Serializer.u8(serializer, UInt8(2))
            try Serializer._struct(serializer, value: result)
        case .nestedResult(let nestedResult):
            try Serializer.u8(serializer, UInt8(3))
            try Serializer._struct(serializer, value: nestedResult)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionObjectArgument {
        let type = try Deserializer.u8(deserializer)

        switch type {
        case 0:
            return TransactionObjectArgument.gasCoin
        case 1:
            return TransactionObjectArgument.input(try Deserializer._struct(deserializer))
        case 2:
            return TransactionObjectArgument.result(try Deserializer._struct(deserializer))
        case 3:
            return TransactionObjectArgument.nestedResult(try Deserializer._struct(deserializer))
        default:
            throw SuiError.customError(message: "Unable to Deserialize")
        }
    }
}
