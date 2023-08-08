//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct GasCostSummary {
    public let computationCost: String
    public let storageCost: String
    public let storageRebate: String
    public let nonRefundableStorageFee: String
}

public struct GasCostSummaryCheckpoint: Equatable {
    public let computationCost: String?
    public let storageCost: String?
    public let storageRebate: String?
    public let nonRefundableStorageFee: String?
}
