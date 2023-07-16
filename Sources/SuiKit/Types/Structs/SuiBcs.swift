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
            try Serializer._struct(serializer, value: pureCallArg)
        case .object(let objectArg):
            try Serializer._struct(serializer, value: objectArg)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> CallArg {
        if let pure: PureSuiCallArg = try? Deserializer._struct(deserializer) {
            return .pure(pure)
        } else if let object: ObjectArg = try? Deserializer._struct(deserializer) {
            return .object(object)
        } else {
            throw SuiError.notImplemented
        }
    }
}
