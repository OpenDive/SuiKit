//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public enum TransactionArgumentKind: Codable, KeyProtocol {
    case object
    case pure(type: String)
    
    public func asString() -> String {
        switch self {
        case .object: return "object"
        case .pure: return "pure"
        }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .object:
            try Serializer.u8(serializer, 0)
        case .pure(let type):
            try Serializer.u8(serializer, 1)
            try Serializer.str(serializer, type)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgumentKind {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionArgumentKind.object
        case 1:
            return TransactionArgumentKind.pure(
                type: try Deserializer.string(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}
