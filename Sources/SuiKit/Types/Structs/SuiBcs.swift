//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation

public indirect enum CallArg: Codable, KeyProtocol {
    case pure(PureSuiCallArg)
    case object(ObjectArg)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .pure(let pureCallArg):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: pureCallArg)
        case .object(let objectArg):
            try Serializer.u8(serializer, 1)
            try Serializer._struct(serializer, value: objectArg)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> CallArg {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return CallArg.pure(
                try Deserializer._struct(deserializer)
            )
        case 1:
            return CallArg.object(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}
