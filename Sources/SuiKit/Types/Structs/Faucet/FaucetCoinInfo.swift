//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct FaucetCoinInfo: Codable {
    public let amount: Int
    public let id: objectId
    public let transferTxDigest: TransactionDigest
}
