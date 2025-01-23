//
//  SuiTransactionBlockResponse.swift
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
import SwiftyJSON

public struct SuiTransactionBlockResponse {
    /// A `TransactionDigest` representing the digest of the transaction block response.
    public let digest: TransactionDigest

    /// An optional `SuiTransactionBlock` representing the transaction block in the response.
    public let transaction: SuiTransactionBlock?

    /// An optional `TransactionEffects` representing the effects of the transaction.
    public let effects: TransactionEffects?

    /// An optional `TransactionEvents` representing the events occurred during the transaction.
    public let events: TransactionEvents?

    /// An optional `String` representing the timestamp of the transaction block response in milliseconds.
    public let timestampMs: String?

    /// An optional `String` representing the checkpoint of the transaction block response.
    public let checkpoint: String?

    /// A `Bool` flag indicating whether the transaction has been confirmed to execute locally.
    public let confirmedLocalExecution: Bool?

    /// An optional array of `SuiObjectChange` representing the object changes occurred during the transaction.
    public let objectChanges: [SuiObjectChange]?

    /// An optional array of `BalanceChange` representing the balance changes occurred during the transaction.
    public let balanceChanges: [BalanceChange]?

    /// An optional array of `String` representing any errors occurred during the transaction block response.
    public let errors: [String]?

    public init(input: JSON) {
        self.digest = input["digest"].stringValue
        self.transaction = SuiTransactionBlock(input: input["transaction"])
        self.effects = TransactionEffects(input: input["effects"])
        self.events = input["events"].arrayValue.compactMap { SuiEvent(input: $0) }
        self.timestampMs = input["timestampMs"].string
        self.checkpoint = input["checkpoint"].string
        self.confirmedLocalExecution = input["confirmedLocalExecution"].bool
        self.objectChanges = input["objectChanges"].arrayValue.compactMap { SuiObjectChange.fromJSON($0) }
        self.balanceChanges = input["balanceChanges"].arrayValue.compactMap { BalanceChange(input: $0) }
        self.errors = input["errors"].arrayValue.compactMap { $0.string }
    }
}
