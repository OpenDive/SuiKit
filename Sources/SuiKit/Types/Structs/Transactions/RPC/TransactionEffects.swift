//
//  TransactionEffects.swift
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

public struct TransactionEffects {
    /// Represents the message version of the transaction effect.
    public var messageVersion: MessageVersion

    /// Represents the execution status of the transaction effect.
    public var status: ExecutionStatus

    /// Represents the epoch in which the transaction was executed.
    public var executedEpoch: EpochId

    /// An optional array representing versions at which the transaction was modified.
    public var modifiedAtVersions: [TransactionEffectsModifiedAtVersions]?

    /// Represents a summary of the gas used by the transaction.
    public var gasUsed: GasCostSummary

    /// An optional array representing shared objects associated with the transaction effect.
    public var sharedObjects: [SuiObjectRef]?

    /// Represents the digest of the transaction.
    public var transactionDigest: TransactionDigest

    /// An optional array representing objects created by the transaction.
    public var created: [OwnedObjectRef]?

    /// An optional array representing objects mutated by the transaction.
    public var mutated: [OwnedObjectRef]?

    /// An optional array representing objects unwrapped by the transaction.
    public var unwrapped: [OwnedObjectRef]?

    /// An optional array representing objects deleted by the transaction.
    public var deleted: [SuiObjectRef]?

    /// An optional array representing objects that were unwrapped then deleted by the transaction.
    public var unwrappedThenDeleted: [SuiObjectRef]?

    /// An optional array representing objects wrapped by the transaction.
    public var wrapped: [SuiObjectRef]?

    /// Represents the gas object associated with the transaction effect.
    public var gasObject: OwnedObjectRef

    /// An optional digest of the events related to the transaction.
    public var eventsDigest: TransactionEventDigest?

    /// An optional array representing the dependencies of the transaction.
    public var dependencies: [TransactionDigest]?

    public init?(input: JSON) {
        guard let messageVersion = MessageVersion.fromJSON(input["messageVersion"]) else { return nil }
        guard let status = ExecutionStatus(input: input["status"]) else { return nil }
        guard let gasObject = OwnedObjectRef(input: input["gasObject"]) else { return nil }

        self.messageVersion = messageVersion
        self.status = status
        self.executedEpoch = input["executedEpoch"].stringValue
        self.modifiedAtVersions = input["modifiedAtVersions"].arrayValue.map {
            TransactionEffectsModifiedAtVersions(input: $0)
        }
        self.gasUsed = GasCostSummary(input: input["gasUsed"])
        self.sharedObjects = input["sharedObjects"].arrayValue.compactMap { SuiObjectRef(input: $0) }
        self.transactionDigest = input["transactionDigest"].stringValue
        self.created = input["created"].arrayValue.compactMap { OwnedObjectRef(input: $0) }
        self.mutated = input["mutated"].arrayValue.compactMap { OwnedObjectRef(input: $0) }
        self.unwrapped = input["unwrapped"].arrayValue.compactMap { OwnedObjectRef(input: $0) }
        self.deleted = input["deleted"].arrayValue.compactMap { SuiObjectRef(input: $0) }
        self.unwrappedThenDeleted = input["unwrappedThenDeleted"].arrayValue.compactMap { SuiObjectRef(input: $0) }
        self.wrapped = input["wrapped"].arrayValue.compactMap { SuiObjectRef(input: $0) }
        self.gasObject = gasObject
        self.eventsDigest = input["eventsDigest"].string
        self.dependencies = input["dependencies"].arrayValue.compactMap { $0.string }
    }
}
