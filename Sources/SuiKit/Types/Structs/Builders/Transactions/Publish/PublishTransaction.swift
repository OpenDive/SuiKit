//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct PublishTransaction: KeyProtocol, Codable {
    public let kind: String
    public let modules: [[UInt8]]
    public let dependencies: [objectId]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, kind)
        try serializer.sequence(modules.map { Data($0) }, Serializer.toBytes)
        try serializer.sequence(dependencies, Serializer.str)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PublishTransaction {
        return PublishTransaction(
            kind: try Deserializer.string(deserializer),
            modules: (try deserializer.sequence(valueDecoder: Deserializer.toBytes)).map { [UInt8]($0) },
            dependencies: try deserializer.sequence(valueDecoder: Deserializer.string)
        )
    }
}
