//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation
import SwiftyJSON

public struct Checkpoint: Equatable {
    public let epoch: String?
    public let sequenceNumber: String?
    public let digest: CheckpointDigest
    public let networkTotalTransactions: String?
    public let previousDigest: CheckpointDigest?
    public let epochRollingGasCostSummary: GasCostSummaryCheckpoint?
    public let timestampMs: String?
    public let validatorSignature: ValidatorSignature?
    public let transactions: [TransactionDigest]

    public init(input: JSON) {
        self.epoch = input["epoch"].string
        self.sequenceNumber = input["sequenceNumber"].string
        self.digest = input["digest"].stringValue
        self.networkTotalTransactions = input["networkTotalTransactions"].string
        self.previousDigest = input["previousDigest"].string
        self.epochRollingGasCostSummary = GasCostSummaryCheckpoint(input: input["epochRollingGasCostSummary"])
        self.timestampMs = input["timestampMs"].string
        self.validatorSignature = input["validatorSignature"].string
        self.transactions = input["transactions"].arrayValue.map { $0.stringValue }
    }
}
