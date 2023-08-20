//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation
import Base58Swift
import SwiftyJSON

public struct SuiObjectRef: KeyProtocol {
    public var objectId: String
    public var version: String
    public var digest: TransactionDigest

    public init(objectId: objectId, version: String, digest: TransactionDigest) {
        self.objectId = objectId
        self.version = version
        self.digest = digest
    }

    public init(objectId: AccountAddress, version: String, digest: TransactionDigest) {
        self.objectId = objectId.hex()
        self.version = version
        self.digest = digest
    }

    public init(input: JSON) {
        self.objectId = input["objectId"].stringValue
        self.version = "\(input["version"].uInt64Value)"
        self.digest = input["digest"].stringValue
    }

    public func serialize(_ serializer: Serializer) throws {
        let account = try AccountAddress.fromHex(self.objectId)
        try Serializer._struct(serializer, value: account)
        try Serializer.u64(serializer, UInt64(version) ?? 0)
        if let dataDigest = Base58.base58Decode(digest) {
            try Serializer.toBytes(serializer, Data(dataDigest))
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiObjectRef {
        return SuiObjectRef(
            objectId: try Deserializer._struct(deserializer),
            version: "\(try Deserializer.u64(deserializer))",
            digest: Base58.base58Encode([UInt8](try Deserializer.toBytes(deserializer)))
        )
    }
}
