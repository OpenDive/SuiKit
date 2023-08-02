//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import UInt256

public enum TransactionArgumentKind: KeyProtocol {
    case object
    case pure(type: TransactionArgumentTypes)
    
    public func asString() -> String {
        switch self {
        case .object: return "object"
        case .pure: return "pure"
        }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .object:
            try Serializer.u8(serializer, UInt8(0))
        case .pure(let type):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: type)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgumentKind {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionArgumentKind.object
        case 1:
            return TransactionArgumentKind.pure(
                type: try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public enum TransactionArgumentTypes: KeyProtocol {
    case u8
    case u64
    case u128
    case address
    case u8Vector
    case bool
    case u16
    case u32
    case u256
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .u8:
            try Serializer.u8(serializer, UInt8(0))
        case .u64:
            try Serializer.u8(serializer, UInt8(1))
        case .u128:
            try Serializer.u8(serializer, UInt8(2))
        case .address:
            try Serializer.u8(serializer, UInt8(3))
        case .u8Vector:
            try Serializer.u8(serializer, UInt8(4))
        case .bool:
            try Serializer.u8(serializer, UInt8(5))
        case .u16:
            try Serializer.u8(serializer, UInt8(6))
        case .u32:
            try Serializer.u8(serializer, UInt8(7))
        case .u256:
            try Serializer.u8(serializer, UInt8(8))
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgumentTypes {
        let result = try Deserializer.u8(deserializer)
        
        switch result {
        case 0:
            return .u8
        case 1:
            return .u64
        case 2:
            return .u128
        case 3:
            return .address
        case 4:
            return .u8Vector
        case 5:
            return .bool
        case 6:
            return .u16
        case 7:
            return .u32
        case 8:
            return .u256
        default:
            throw SuiError.notImplemented
        }
    }
}
