//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable
import SwiftyJSON

public enum TransactionArgument: KeyProtocol, Codable {
    case input(TransactionBlockInput)
    case gasCoin
    case result(Result)
    case nestedResult(NestedResult)
    
    // TODO: Implement fromJsonObject function
//    public static func fromJsonObject(_ data: JSON, _ type: String) throws -> TransactionArgument {
//        enum TransactionArgumentType: String {
//            case input = "Input"
//            case gasCoin = "GasCoin"
//            case result = "Result"
//            case nestedResult = "NestedResult"
//        }
//        
//        guard let txType = TransactionArgumentType(rawValue: type) else { throw SuiError.notImplemented }
//        
//        switch txType {
//        case .input:
//            return .input(
//                TransactionBlockInput(
//                    index: , // Int
//                    value: , // SuiJsonValue?
//                    type:  // ValueType?
//                )
//            )
//        case .gasCoin:
//            return .gasCoin
//        case .result:
//            return .result(
//                Result(
//                    index:  // Int
//                )
//            )
//        case .nestedResult:
//            return .nestedResult(
//                NestedResult(
//                    index: , // Int
//                    resultIndex:  // Int
//                )
//            )
//        }
//    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .input(let transactionBlockInput):
            try Serializer._struct(serializer, value: transactionBlockInput)
        case .gasCoin:
            try Serializer.str(serializer, "GasCoin")
        case .result(let result):
            try Serializer._struct(serializer, value: result)
        case .nestedResult(let nestedResult):
            try Serializer._struct(serializer, value: nestedResult)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgument {
        if let input: TransactionBlockInput = try? Deserializer._struct(deserializer) {
            return .input(input)
        } else if let _ = try? Deserializer.string(deserializer) {
            return .gasCoin
        } else if let result: Result = try? Deserializer._struct(deserializer) {
            return .result(result)
        } else if let nestedResult: NestedResult = try? Deserializer._struct(deserializer) {
            return .nestedResult(nestedResult)
        } else {
            throw SuiError.notImplemented
        }
    }
}

public struct TransactionBlockInput: KeyProtocol, TransactionArgumentTypeProtocol, Codable {
    public var index: Int
    public var value: SuiJsonValue?
    public var type: ValueType?
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u64(serializer, UInt64(index))
        if let value { try Serializer._struct(serializer, value: value) }
        if let type { try Serializer._struct(serializer, value: type) }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionBlockInput {
        return TransactionBlockInput(
            index: Int(try Deserializer.u64(deserializer)),
            value: try Deserializer._struct(deserializer),
            type: try Deserializer._struct(deserializer)
        )
    }
}

public enum ValueType: String, KeyProtocol, Codable {
    case pure
    case object
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .pure:
            try Serializer.str(serializer, "Pure")
        case .object:
            try Serializer.str(serializer, "Object")
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ValueType {
        let type = try Deserializer.string(deserializer)
        
        switch type {
        case "Pure":
            return ValueType.pure
        case "Object":
            return ValueType.object
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct Result: KeyProtocol, TransactionArgumentTypeProtocol, Codable {
    public let index: Int
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u64(serializer, UInt64(index))
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Result {
        return Result(
            index: Int(try Deserializer.u64(deserializer))
        )
    }
}

public struct NestedResult: KeyProtocol, TransactionArgumentTypeProtocol, Codable {
    public let index: Int
    public let resultIndex: Int
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u64(serializer, UInt64(index))
        try Serializer.u64(serializer, UInt64(resultIndex))
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> NestedResult {
        return NestedResult(
            index: Int(try Deserializer.u64(deserializer)),
            resultIndex: Int(try Deserializer.u64(deserializer))
        )
    }
}

public struct ObjectTransactionArgument: Codable, KeyProtocol {
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

public struct PureTransactionArgument: Codable, KeyProtocol {
    public let argument: TransactionArgument
    public let kind: TransactionArgumentKind
    
    public init(argument: TransactionArgument, type: String) {
        self.argument = argument
        self.kind = .pure(type: type)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: argument)
        try Serializer._struct(serializer, value: kind)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PureTransactionArgument {
        let argument: TransactionArgument = try Deserializer._struct(deserializer)
        let kindEnum: TransactionArgumentKind = try Deserializer._struct(deserializer)
        
        switch kindEnum {
        case .pure(let type):
            return PureTransactionArgument(
                argument: argument,
                type: type
            )
        default:
            throw SuiError.notImplemented
        }
    }
}
