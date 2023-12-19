//
//  File.swift
//  
//
//  Created by Marcus Arnett on 11/17/23.
//

import Foundation

public enum TransactionObjectInput {
    case string(String)
    case objectCallArg(ObjectCallArg)
    case transactionObjectArgument(TransactionObjectArgument)
}
