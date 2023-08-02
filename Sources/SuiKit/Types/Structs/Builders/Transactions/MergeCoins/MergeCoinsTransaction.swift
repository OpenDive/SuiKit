//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MergeCoinsTransaction: KeyProtocol {
    public let kind: SuiTransactionKindName
    public let destination: ObjectTransactionArgument
    public let sources: [ObjectTransactionArgument]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: kind)
        try Serializer._struct(serializer, value: destination)
        try serializer.sequence(sources, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            kind: try Deserializer._struct(deserializer),
            destination: try Deserializer._struct(deserializer),
            sources: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
