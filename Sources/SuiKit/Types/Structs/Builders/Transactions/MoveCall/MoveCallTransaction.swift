//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation

public struct MoveCallTransaction: Codable, KeyProtocol {
    public let kind: String
    public let target: String
    public let typeArguments: [String]
    public let arguments: [TransactionArgument]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, kind)
        try Serializer.str(serializer, target)
        try serializer.sequence(typeArguments, Serializer.str)
        try serializer.sequence(arguments, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MoveCallTransaction {
        return MoveCallTransaction(
            kind: try Deserializer.string(deserializer),
            target: try Deserializer.string(deserializer),
            typeArguments: try deserializer.sequence(valueDecoder: Deserializer.string),
            arguments: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
