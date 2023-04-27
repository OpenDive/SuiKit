//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct Balance: Codable {
    let coinType: String
    let coinObjectCount: Int
    let totalBalance: UInt64
}
