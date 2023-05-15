//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MergeCoinsTransaction: TransactionTypesProtocol {
    public let kind: String
    public let destination: ObjectTransactionArgument
    public let sources: [ObjectTransactionArgument]
}
