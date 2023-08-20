//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct PublishTransaction: KeyProtocol, TransactionProtocol {
    public let modules: [[UInt8]]
    public let dependencies: [AccountAddress]
    
    public init(modules: [[UInt8]], dependencies: [objectId]) throws {
        self.modules = modules
        self.dependencies = try dependencies.map { try AccountAddress.fromHex($0) }
    }

    public init?(input: JSON) {
        let publish = input.arrayValue
        self.modules = publish[0].arrayValue.map { $0.arrayValue.map { $0.uInt8Value } }
        self.dependencies = publish[1].arrayValue.compactMap { try? AccountAddress.fromHex($0.stringValue) }
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(modules.map { Data($0) }, Serializer.toBytes)
        try serializer.uleb128(UInt(self.dependencies.count))
        for dependency in dependencies {
            try Serializer._struct(serializer, value: dependency)
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
