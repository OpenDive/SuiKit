//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation
import Base58Swift

public struct SuiObjectRef: KeyProtocol {
    public var objectId: String
    public var version: UInt64
    public var digest: TransactionDigest
    
    public init(objectId: objectId, version: UInt64, digest: TransactionDigest) {
        self.objectId = objectId
        self.version = version
        self.digest = digest
    }
    
    public func serialize(_ serializer: Serializer) throws {
        let publicKey = try ED25519PublicKey(hexString: objectId)
        publicKey.serializeModule(serializer)
        try Serializer.u64(serializer, version)
        if let dataDigest = Base58.base58Decode(digest) {
            try Serializer.toBytes(serializer, Data(dataDigest))
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiObjectRef {
        return SuiObjectRef(
            objectId: try Deserializer.string(deserializer),
            version: try Deserializer.u64(deserializer),
            digest: try Deserializer.string(deserializer)
        )
    }
}
