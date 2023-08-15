//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MakeMoveVecTransaction: KeyProtocol, TransactionProtocol {
    public let objects: [ObjectTransactionArgument]
    public let type: String?
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(objects, Serializer._struct)
        if let type { try Serializer.str(serializer, type) }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MakeMoveVecTransaction {
        return MakeMoveVecTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            type: try? Deserializer.string(deserializer)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try self.objects.forEach { argument in
            try argument.argument.encodeInput(objects: &objects, inputs: &inputs)
        }
    }
}
