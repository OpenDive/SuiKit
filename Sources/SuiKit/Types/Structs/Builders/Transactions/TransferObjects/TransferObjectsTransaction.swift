//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct TransferObjectsTransaction: KeyProtocol, TransactionProtocol {
    public var objects: [ObjectTransactionArgument]
    public var address: PureTransactionArgument
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(objects, Serializer._struct)
        try Serializer._struct(serializer, value: address)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            address: try Deserializer._struct(deserializer)
        )
    }
    
    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try self.objects.forEach { argument in
            try argument.argument.encodeInput(objects: &objects, inputs: &inputs)
        }
        try self.address.argument.encodeInput(objects: &objects, inputs: &inputs)
    }
}
