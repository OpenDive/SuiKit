//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/20/23.
//

import Foundation

public struct SuiTransactionBlockResponseQuery: Codable {
    public var filter: TransactionFilter?
    public var options: SuiTransactionBlockResponseOptions?
}
