//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation

public struct TransactionResponse {
    public let txBytes: String
    public let gas: SuiObjectRef
    public let inputObjects: [String: SuiObjectRef]
}
