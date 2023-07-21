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
        let kind = try Deserializer.string(deserializer)
        let target = try Deserializer.string(deserializer)
        let typeArguments = try deserializer.sequence(valueDecoder: Deserializer.string)
        let arguments: [TransactionArgument] = try deserializer.sequence(valueDecoder: Deserializer._struct)
        return MoveCallTransaction(
            kind: kind,
            target: target,
            typeArguments: typeArguments,
            arguments: arguments
        )
    }
}
