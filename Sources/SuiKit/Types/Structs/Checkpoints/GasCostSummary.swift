//
//  GasCostSummary.swift
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

/// Represents a summary of the gas costs in a blockchain transaction or operation.
/// Gas is a unit that measures the amount of computational effort required to execute operations, like making transactions or running dApps.
public struct GasCostSummary: Equatable {
    /// A string representing the cost of computation in the transaction or operation.
    /// This cost is associated with the execution of smart contract code or transaction processing.
    public let computationCost: String

    /// A string representing the cost associated with storing data in the transaction or operation.
    /// This can include costs related to saving data on the blockchain.
    public let storageCost: String

    /// A string representing the rebate for storage in the transaction or operation.
    /// This can include any reductions or refunds on the overall storage cost.
    public let storageRebate: String

    /// A string representing any non-refundable storage fee in the transaction or operation.
    /// This refers to the portion of the storage cost that cannot be recovered or refunded.
    public let nonRefundableStorageFee: String

    /// Initialize a new instance of `GasCostSummary` from a GraphQL object.
    /// - Parameter graphql: A GraphQL object containing values for initalizing a new Checkpoint.
    public init(graphql: RPC_Checkpoint_Fields.RollingGasSummary) {
        self.computationCost = graphql.computationCost ?? ""
        self.storageCost = graphql.storageCost ?? ""
        self.storageRebate = graphql.storageRebate ?? ""
        self.nonRefundableStorageFee = graphql.nonRefundableStorageFee ?? ""
    }

    /// Initializes a new `GasCostSummary` instance with the given JSON input.
    /// - Parameter input: A `JSON` object containing the computationCost, storageCost, storageRebate, and nonRefundableStorageFee values.
    public init(input: JSON) {
        self.computationCost = input["computationCost"].stringValue
        self.storageCost = input["storageCost"].stringValue
        self.storageRebate = input["storageRebate"].stringValue
        self.nonRefundableStorageFee = input["nonRefundableStorageFee"].stringValue
    }
}
