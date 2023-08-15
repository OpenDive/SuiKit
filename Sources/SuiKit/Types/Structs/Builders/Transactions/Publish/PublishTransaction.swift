//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct PublishTransaction: KeyProtocol, TransactionProtocol {
    public let modules: [[UInt8]]
    public let dependencies: [ED25519PublicKey]
    
    public init(modules: [[UInt8]], dependencies: [objectId]) throws {
        self.modules = modules
        self.dependencies = try dependencies.map { try ED25519PublicKey(hexString: $0) }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(modules.map { Data($0) }, Serializer.toBytes)
        try serializer.uleb128(UInt(self.dependencies.count))
        for dependency in dependencies {
            dependency.serializeModule(serializer)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: (try deserializer.sequence(valueDecoder: Deserializer.toBytes)).map { [UInt8]($0) },
            dependencies: try deserializer.sequence(valueDecoder: Deserializer.string)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        return
    }
}
