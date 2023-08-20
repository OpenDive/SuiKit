//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct SplitCoinsTransaction: KeyProtocol, TransactionProtocol {
    public var coin: TransactionArgument
    public var amounts: [TransactionArgument]

    public init(coin: TransactionArgument, amounts: [TransactionArgument]) {
        self.coin = coin
        self.amounts = amounts
    }

    public init?(input: JSON) {
        let split = input.arrayValue
        guard let coin = TransactionArgument.fromJSON(split[0]) else { return nil }
        self.coin = coin
        self.amounts = split[1].arrayValue.compactMap { TransactionArgument.fromJSON($0) }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: coin)
        try serializer.sequence(amounts, Serializer._struct)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            coin: try Deserializer._struct(deserializer),
            amounts: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try self.amounts.forEach { argument in
            try argument.encodeInput(objects: &objects, inputs: &inputs)
        }
        try self.coin.encodeInput(objects: &objects, inputs: &inputs)
    }
}
