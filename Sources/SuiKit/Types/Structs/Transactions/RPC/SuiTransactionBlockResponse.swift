//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiTransactionBlockResponse {
    public let digest: TransactionDigest
    public let transaction: SuiTransactionBlock?
    public let effects: TransactionEffects?
    public let events: TransactionEvents?
    public let timestampMs: String?
    public let checkpoint: String?
    public let confirmedLocalExecution: Bool?
    public let objectChanges: [SuiObjectChange]?
    public let balanceChanges: [BalanceChange]?
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

public struct PaginatedTransactionResponse {
    public let data: [SuiTransactionBlockResponse]
    public let nextCursor: TransactionDigest?
    public let hasNextPage: Bool
}
