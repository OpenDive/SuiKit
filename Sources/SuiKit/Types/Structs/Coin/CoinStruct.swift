//
//  CoinStruct.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import graphqlSchemaSuiKit

/// Represents the details of a specific coin object.
public struct CoinStruct: Equatable {
    /// A string representing the type of the coin, e.g., Bitcoin, Ethereum.
    public let coinType: StructTag

    /// An `objectId` representing the unique identifier of the coin object.
    public let coinObjectId: ObjectId

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

    public init(graphql: graphqlSchemaSuiKit.Coin) throws {
        guard let contents = graphql.asMoveObject?.contents else {
            throw SuiError.customError(message: "Invalid Coin Object")
        }
        self.coinType = try StructTag.fromStr(contents.type.repr)
        self.coinObjectId = graphql.address
        self.version = String(graphql.version)
        self.digest = graphql.digest
        if let balanceBigInt = graphql.balance {
            self.balance = String(balanceBigInt.description)
        } else {
            self.balance = "0"
        }
        self.previousTransaction = graphql.previousTransactionBlock?.digest ?? ""
    }

    public init(
        coinType: String,
        coinObjectId: ObjectId,
        version: String,
        digest: TransactionDigest,
        balance: String,
        previousTransaction: TransactionDigest
    ) throws {
        self.coinType = try StructTag.fromStr(coinType)
        self.coinObjectId = coinObjectId
        self.version = version
        self.digest = digest
        self.balance = balance
        self.previousTransaction = previousTransaction
    }
}

public typealias ObjectId = String
