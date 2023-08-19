//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation
import SwiftyJSON

public struct GasCostSummary {
    public let computationCost: String
    public let storageCost: String
    public let storageRebate: String
    public let nonRefundableStorageFee: String

    public init(input: JSON) {
        self.computationCost = input["computationCost"].stringValue
        self.storageCost = input["storageCost"].stringValue
        self.storageRebate = input["storageRebate"].stringValue
        self.nonRefundableStorageFee = input["nonRefundableStorageFee"].stringValue
    }
}

public struct GasCostSummaryCheckpoint: Equatable {
    public let computationCost: String?
    public let storageCost: String?
    public let storageRebate: String?
    public let nonRefundableStorageFee: String?

    public init(input: JSON) {
        self.computationCost = input["computationCost"].stringValue
        self.storageCost = input["storageCost"].stringValue
        self.storageRebate = input["storageRebate"].stringValue
        self.nonRefundableStorageFee = input["nonRefundableStorageFee"].stringValue
    }
}
