//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MoveCallTransactionInput {
    let target: String
    var arguments: [TransactionArgument]?
    var typeArguments: [String]?
}
