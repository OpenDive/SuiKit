//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation

public struct SuiObjectRef: Codable, KeyProtocol {
    public let version: UInt8
    public let objectId: objectId
    public let digest: TransactionDigest
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, version)
        try Serializer.str(serializer, objectId)
        try Serializer.str(serializer, digest)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiObjectRef {
        return SuiObjectRef(
            version: try Deserializer.u8(deserializer),
            objectId: try Deserializer.string(deserializer),
            digest: try Deserializer.string(deserializer)
        )
    }
}
