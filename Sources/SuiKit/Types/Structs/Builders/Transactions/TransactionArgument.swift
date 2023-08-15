//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable
import SwiftyJSON

public enum TransactionArgumentName: String, KeyProtocol {
    case gasCoin = "GasCoin"
    case input = "Input"
    case result = "Result"
    case nestedResult = "NestedResult"
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .gasCoin:
            try Serializer.u8(serializer, UInt8(0))
        case .input:
            try Serializer.u8(serializer, UInt8(1))
        case .result:
            try Serializer.u8(serializer, UInt8(2))
        case .nestedResult:
            try Serializer.u8(serializer, UInt8(3))
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgumentName {
        let result = try Deserializer.u8(deserializer)
        switch result {
        case 0:
            return .gasCoin
        case 1:
            return .input
        case 2:
            return .result
        case 3:
            return .nestedResult
        default:
            throw SuiError.notImplemented
        }
    }
}

public enum TransactionArgument: KeyProtocol {
    case gasCoin
    case input(TransactionBlockInput)
    case result(Result)
    case nestedResult(NestedResult)
    
    public var kind: TransactionArgumentName {
        switch self {
        case .gasCoin:
            return .gasCoin
        case .input:
            return .input
        case .result:
            return .result
        case .nestedResult:
            return .nestedResult
        }
    }

    public func encodeInput(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        switch self {
        case .input(let transactionBlockInput):
            try self.encodeInput(with: &(inputs[Int(transactionBlockInput.index)]), objects: &objects)
        default:
            return
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
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgument {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionArgument.input(try Deserializer._struct(deserializer))
        case 1:
            return TransactionArgument.gasCoin
        case 2:
            return TransactionArgument.result(try Deserializer._struct(deserializer))
        case 3:
            return TransactionArgument.nestedResult(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }

    private func encodeInput(
        with input: inout TransactionBlockInput,
        objects: inout [ObjectsToResolve]
    ) throws {
        guard let value = input.value, let type = input.type else { throw SuiError.notImplemented }

        switch value {
        case .callArg:
            return
        case .string(let str):
            switch type {
            case .object:
                objects.append(ObjectsToResolve(id: str, input: input, normalizedType: nil))
            default:
                input.value = .input(Inputs.pure(data: try value.dataValue()))
            }
        default:
            switch type {
            case .pure:
                input.value = .input(Inputs.pure(data: try value.dataValue()))
            case .object:
                throw SuiError.notImplemented
            }
        }
    }
}

public struct TransactionBlockInput: KeyProtocol, TransactionArgumentTypeProtocol {
    public var index: UInt16
    public var value: SuiJsonValue?
    public var type: ValueType?
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionBlockInput {
        throw SuiError.notImplemented
    }
}

public enum ValueType: KeyProtocol, Codable {
    case pure
    case object
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .pure:
            try Serializer.u8(serializer, UInt8(0))
        case .object:
            try Serializer.u8(serializer, UInt8(1))
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ValueType {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return ValueType.pure
        case 1:
            return ValueType.object
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct Result: KeyProtocol, TransactionArgumentTypeProtocol, Codable {
    public let index: UInt16
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Result {
        return Result(
            index: try Deserializer.u16(deserializer)
        )
    }
}

public struct NestedResult: KeyProtocol, TransactionArgumentTypeProtocol, Codable {
    public let index: UInt16
    public let resultIndex: UInt16
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
        try Serializer.u16(serializer, resultIndex)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> NestedResult {
        return NestedResult(
            index: try Deserializer.u16(deserializer),
            resultIndex: try Deserializer.u16(deserializer)
        )
    }
}

public struct ObjectTransactionArgument: KeyProtocol {
    public let argument: TransactionArgument
    public let kind: TransactionArgumentKind
    
    public init(argument: TransactionArgument) {
        self.argument = argument
        self.kind = .object
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: argument)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ObjectTransactionArgument {
        return ObjectTransactionArgument(
            argument: try Deserializer._struct(deserializer)
        )
    }
}

public struct PureTransactionArgument: KeyProtocol {
    public let argument: TransactionArgument
    public let kind: TransactionArgumentKind
    
    public init(argument: TransactionArgument, type: TransactionArgumentTypes) {
        self.argument = argument
        self.kind = .pure(type: type)
    }
    
    public func serialize(_ serializer: Serializer) throws {
//        try Serializer._struct(serializer, value: kind)
        try Serializer._struct(serializer, value: argument)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PureTransactionArgument {
//        let kindEnum: TransactionArgumentKind = try Deserializer._struct(deserializer)
//        let argument: TransactionArgument = try Deserializer._struct(deserializer)
//        
//        switch kindEnum {
//        case .pure(let type):
//            return PureTransactionArgument(
//                argument: argument,
//                type: type
//            )
//        default:
//            throw SuiError.notImplemented
//        }
        throw SuiError.notImplemented
    }
}
