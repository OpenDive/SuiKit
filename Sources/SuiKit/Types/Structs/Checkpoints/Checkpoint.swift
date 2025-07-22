//
//  Checkpoint.swift
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

/// Represents a checkpoint in the blockchain, capturing various attributes and states at that point in time.
public struct Checkpoint: Equatable {
    /// Represents the epoch of the checkpoint, it may be nil.
    public let epoch: String?

    /// Represents the sequence number of the checkpoint, it may be nil.
    public let sequenceNumber: String?

    /// Represents the digest of the checkpoint.
    public let digest: CheckpointDigest

    /// Represents the total number of transactions in the network until this checkpoint, it may be nil.
    public let networkTotalTransactions: String?

    /// Represents the digest of the previous checkpoint, it may be nil.
    public let previousDigest: CheckpointDigest?

    /// Represents the summary of the gas cost in the epoch rolling until this checkpoint, it may be nil.
    public let epochRollingGasCostSummary: GasCostSummary?

    /// Represents the timestamp in milliseconds when the checkpoint was created, it may be nil.
    public let timestampMs: String?

    /// Represents the signature of the validator for this checkpoint, it may be nil.
    public let validatorSignature: ValidatorSignature?

    /// Represents the array of transaction digests included in this checkpoint.
    public let transactions: [TransactionDigest]

    /// Initialize a new instance of `Checkpoint` from a GraphQL object.
    /// - Parameter graphql: A GraphQL object containing values for initalizing a new Checkpoint.
    public init(graphql: GetCheckpointQuery.Data) {
        self.epoch = "\(graphql.checkpoint!.epoch!.epochId)"
        self.sequenceNumber = "\(graphql.checkpoint!.sequenceNumber)"
        self.digest = graphql.checkpoint!.digest
        self.networkTotalTransactions = graphql.checkpoint!.networkTotalTransactions != nil ?
            "\(graphql.checkpoint!.networkTotalTransactions!)" :
            nil
        self.previousDigest = graphql.checkpoint!.previousCheckpointDigest
        self.epochRollingGasCostSummary = graphql.checkpoint!.rollingGasSummary != nil ?
            GasCostSummary(graphql: graphql.checkpoint!.rollingGasSummary!) :
            nil
        self.timestampMs = "\(DateFormatter.unixTimestamp(from: graphql.checkpoint!.timestamp)!)"
        self.validatorSignature = graphql.checkpoint!.validatorSignatures
        self.transactions = graphql.checkpoint!.transactionBlocks.nodes.compactMap { $0.digest }
    }

    /// Initialize a new instance of `Checkpoint` from a GraphQL object.
    /// - Parameter graphql: A GraphQL object containing values for initalizing a new Checkpoint.
    public init(graphql: GetCheckpointsQuery.Data.Checkpoints.Node) {
        self.epoch = "\(graphql.epoch!.epochId)"
        self.sequenceNumber = "\(graphql.sequenceNumber)"
        self.digest = graphql.digest
        self.networkTotalTransactions = graphql.networkTotalTransactions != nil ?
            "\(graphql.networkTotalTransactions!)" :
            nil
        self.previousDigest = graphql.previousCheckpointDigest
        self.epochRollingGasCostSummary = graphql.rollingGasSummary != nil ?
            GasCostSummary(graphql: graphql.rollingGasSummary!) :
            nil
        self.timestampMs = "\(DateFormatter.unixTimestamp(from: graphql.timestamp)!)"
        self.validatorSignature = graphql.validatorSignatures
        self.transactions = graphql.transactionBlocks.nodes.compactMap { $0.digest }
    }

    /// Initializes a new instance of `Checkpoint` from a JSON object.
    /// - Parameter input: A JSON object containing values for initializing a new Checkpoint.
    public init(input: JSON) {
        self.epoch = input["epoch"].string
        self.sequenceNumber = input["sequenceNumber"].string
        self.digest = input["digest"].stringValue
        self.networkTotalTransactions = input["networkTotalTransactions"].string
        self.previousDigest = input["previousDigest"].string
        self.epochRollingGasCostSummary = GasCostSummary(
            input: input["epochRollingGasCostSummary"]
        )
        self.timestampMs = input["timestampMs"].string
        self.validatorSignature = input["validatorSignature"].string
        self.transactions = input["transactions"].arrayValue.map { $0.stringValue }
    }
}
