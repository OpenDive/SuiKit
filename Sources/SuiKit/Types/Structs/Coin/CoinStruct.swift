//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct CoinStruct {
    public let coinType: String
    public let coinObjectId: objectId
    public let version: String
    public let digest: TransactionDigest
    public let balance: String
    public let previousTransaction: TransactionDigest
}

public typealias objectId = String
