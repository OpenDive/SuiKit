//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct ProgrammableTransaction: KeyProtocol {
    public let inputs: [Input]
    public let transactions: [SuiTransaction]

    public init(inputs: [Input], transactions: [SuiTransaction]) {
        self.inputs = inputs
        self.transactions = transactions
    }

    public init(input: JSON) {
        self.inputs = input["inputs"].arrayValue.compactMap { Input(input: $0) }
        self.transactions = input["transactions"].arrayValue.compactMap { SuiTransaction.fromJSON($0) }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(inputs, Serializer._struct)
        try serializer.sequence(transactions, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ProgrammableTransaction {
        return ProgrammableTransaction(
            inputs: try deserializer.sequence(valueDecoder: Deserializer._struct),
            transactions: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
