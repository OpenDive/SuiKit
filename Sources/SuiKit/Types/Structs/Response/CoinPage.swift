//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct CoinPage: Codable {
    let coinType: String
    let coinObjectId: String
    let version: String
    let digest: String
    let balance: UInt64
    let previousTransaction: String
}
