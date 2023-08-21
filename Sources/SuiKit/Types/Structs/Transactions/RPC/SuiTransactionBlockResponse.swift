//
//  SuiTransactionBlockResponse.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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
