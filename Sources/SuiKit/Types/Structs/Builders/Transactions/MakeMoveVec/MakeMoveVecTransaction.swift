//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MakeMoveVecTransaction: TransactionTypesProtocol {
    public let kind: String
    public let objects: ObjectTransactionArgument
    public let type: TypeTag?
}
