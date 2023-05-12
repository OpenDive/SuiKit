//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct SplitCoinsTransaction {
    public let kind: String
    public let coin: ObjectTransactionArgument
    public let amounts: [PureTransactionArgument]
}
