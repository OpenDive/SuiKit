//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation

public struct MoveCallTransaction: Codable, TransactionTypesProtocol {
    public let kind: String
    public let target: String
    public let typeArguments: [String]
    public let arguments: [TransactionArgument]
}
