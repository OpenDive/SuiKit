//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation
import Base58Swift

public struct SuiObjectRef: KeyProtocol {
    public let objectId: any PublicKeyProtocol
    public let version: UInt64
    public let digest: TransactionDigest
    
    public init(objectId: objectId, version: UInt64, digest: TransactionDigest) throws {
        self.objectId = try ED25519PublicKey(hexString: objectId)
        self.version = version
        self.digest = digest
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: objectId)
        try Serializer.u64(serializer, version)
        if let dataDigest = Base58.base58Decode(digest) {
            try Serializer.toBytes(serializer, Data(dataDigest))
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiObjectRef {
        return try SuiObjectRef(
            objectId: try Deserializer.string(deserializer),
            version: try Deserializer.u64(deserializer),
            digest: try Deserializer.string(deserializer)
        )
    }
}
