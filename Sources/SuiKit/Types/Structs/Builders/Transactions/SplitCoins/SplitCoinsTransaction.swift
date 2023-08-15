//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct SplitCoinsTransaction: KeyProtocol, TransactionProtocol {
    public var coin: ObjectTransactionArgument
    public var amounts: [PureTransactionArgument]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: coin)
        try serializer.sequence(amounts, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            coin: ObjectTransactionArgument(argument: .gasCoin),
            amounts: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try self.amounts.forEach { argument in
            try argument.argument.encodeInput(objects: &objects, inputs: &inputs)
        }
        try self.coin.argument.encodeInput(objects: &objects, inputs: &inputs)
    }
}
