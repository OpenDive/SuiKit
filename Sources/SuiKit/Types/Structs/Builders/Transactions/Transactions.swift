//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable

public struct Transactions {
    public static func moveCall(input: MoveCallTransactionInput) -> MoveCallTransaction {
        return MoveCallTransaction(
            kind: "MoveCall",
            target: input.target,
            typeArguments: input.typeArguments ?? [],
            arguments: input.arguments ?? []
        )
    }
    
    public static func transferObjects(objects: [ObjectTransactionArgument], address: PureTransactionArgument) -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            kind: "TransferObject",
            objects: objects,
            address: address
        )
    }
    
    public static func splitCoins(coins: ObjectTransactionArgument, amounts: [TransactionArgument]) -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            kind: "SplitCoins",
            coin: coins,
            amounts: amounts.map { PureTransactionArgument(argument: $0, type: "u64") }
        )
    }
}
