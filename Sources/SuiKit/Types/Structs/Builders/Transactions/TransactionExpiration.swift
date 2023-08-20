//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public enum TransactionExpiration: KeyProtocol {
    case none(Bool)
    case epoch(UInt64)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .none:
            try Serializer.u8(serializer, UInt8(0))
        case .epoch(let int):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer.u64(serializer, UInt64(int))
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionExpiration {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionExpiration.none(true)
        case 1:
            return TransactionExpiration.epoch(
                try Deserializer.u64(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}
