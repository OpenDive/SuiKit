//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MergeCoinsTransaction: KeyProtocol, TransactionProtocol {
    public let destination: ObjectTransactionArgument
    public let sources: [ObjectTransactionArgument]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: destination)
        try serializer.sequence(sources, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            destination: try Deserializer._struct(deserializer),
            sources: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try destination.argument.encodeInput(objects: &objects, inputs: &inputs)

        try sources.forEach { argument in
            try argument.argument.encodeInput(objects: &objects, inputs: &inputs)
        }
    }
}
