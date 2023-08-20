//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiTransactionBlock {
    public let data: SuiTransactionBlockData
    public let txSignature: [String]

    public init?(input: JSON) {
        guard let data = SuiTransactionBlockData(input: input["data"]) else { return nil }
        self.data = data
        self.txSignature = input["txSignature"].arrayValue.map { $0.stringValue }
    }
}
