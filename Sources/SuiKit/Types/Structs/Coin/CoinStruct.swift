//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

/// Represents the details of a specific coin object.
public struct CoinStruct {
    /// A string representing the type of the coin, e.g., Bitcoin, Ethereum.
    public let coinType: String

    /// An `objectId` representing the unique identifier of the coin object.
    public let coinObjectId: objectId

    /// A string representing the version of the coin object.
    /// This can be used to track the changes or updates made to the coin object.
    public let version: String

    /// A `TransactionDigest` representing the summary or the hash
    /// of the transaction associated with this coin object.
    public let digest: TransactionDigest

    /// A string representing the balance associated with this coin object.
    public let balance: String

    /// A `TransactionDigest` representing the summary or the hash
    /// of the previous transaction associated with this coin object.
    public let previousTransaction: TransactionDigest

    /// Converts the `CoinStruct` instance to a `SuiObjectData` instance.
    /// - Returns: A `SuiObjectData` instance containing relevant data from `CoinStruct`.
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

    /// Converts the `CoinStruct` instance to a `SuiObjectRef` instance.
    /// - Returns: A `SuiObjectRef` instance containing relevant references from `CoinStruct`.
    public func toSuiObjectRef() -> SuiObjectRef {
        return SuiObjectRef(
            objectId: self.coinObjectId,
            version: self.version,
            digest: self.digest
        )
    }

    public init(graphql: GetCoinsQuery.Data.Address.CoinConnection.Node) {
        self.balance = graphql.balance!
        self.coinObjectId = graphql.asMoveObject.asObject.coinObjectId
        self.coinType = graphql.asMoveObject.contents!.type.repr
        self.digest = graphql.asMoveObject.asObject.digest
        self.previousTransaction = graphql.asMoveObject.asObject.previousTransactionBlock!.digest
        self.version = "\(graphql.asMoveObject.asObject.version)"
    }
}

public typealias objectId = String
