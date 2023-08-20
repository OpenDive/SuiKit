//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct CoinStruct {
    public let coinType: String
    public let coinObjectId: objectId
    public let version: String
    public let digest: TransactionDigest
    public let balance: String
    public let previousTransaction: TransactionDigest

    public func toSuiObjectData() -> SuiObjectData {
        return SuiObjectData(
            bcs: nil,
            content: nil,
            digest: self.digest,
            display: nil,
            objectId: self.coinObjectId,
            owner: nil,
            previousTransaction: self.previousTransaction,
            storageRebate: nil,
            type: nil,
            version: self.version
        )
    }

    public func toSuiObjectRef() -> SuiObjectRef {
        return SuiObjectRef(
            objectId: self.coinObjectId,
            version: self.version,
            digest: self.digest
        )
    }
}

public typealias objectId = String
