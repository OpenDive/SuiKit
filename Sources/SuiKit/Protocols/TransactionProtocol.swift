//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/11/23.
//

import Foundation

public protocol TransactionProtocol: KeyProtocol {
    func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws
}
