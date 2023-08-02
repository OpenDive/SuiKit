//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct TransferObjectsTransaction: KeyProtocol {
    public let objects: [ObjectTransactionArgument]
    public let address: PureTransactionArgument
    
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
}
