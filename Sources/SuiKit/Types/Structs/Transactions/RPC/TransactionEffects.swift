//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct TransactionEffects {
    public var messageVersion: MessageVersion
    public var status: ExecutionStatus
    public var executedEpoch: EpochId
    public var modifiedAtVersions: [TransactionEffectsModifiedAtVersions]?
    public var gasUsed: GasCostSummary
    public var sharedObjects: [SuiObjectRef]?
    public var transactionDigest: TransactionDigest
    public var created: [OwnedObjectRef]?
    public var mutated: [OwnedObjectRef]?
    public var unwrapped: [OwnedObjectRef]?
    public var deleted: [SuiObjectRef]?
    public var unwrappedThenDeleted: [SuiObjectRef]?
    public var wrapped: [SuiObjectRef]?
    public var gasObject: OwnedObjectRef
    public var eventsDigest: TransactionEventDigest?
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
