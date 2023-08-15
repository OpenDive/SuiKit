//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct UpgradeTransaction: KeyProtocol, TransactionProtocol {
    public let modules: [[UInt8]]
    public let dependencies: [objectId]
    public let packageId: objectId
    public let ticket: ObjectTransactionArgument
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, modules.map { Data($0) })
        try serializer.sequence(dependencies, Serializer.str)
        try Serializer.str(serializer, packageId)
        try Serializer._struct(serializer, value: ticket)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> UpgradeTransaction {
        return UpgradeTransaction(
            modules: (try deserializer.sequence(valueDecoder: Deserializer.toBytes)).map { [UInt8]($0) },
            dependencies: try deserializer.sequence(valueDecoder: Deserializer.string),
            packageId: try Deserializer.string(deserializer),
            ticket: try Deserializer._struct(deserializer)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try ticket.argument.encodeInput(objects: &objects, inputs: &inputs)
    }
}
