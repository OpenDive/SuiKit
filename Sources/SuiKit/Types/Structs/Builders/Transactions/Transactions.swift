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
            kind: .moveCall,
            target: input.target,
            typeArguments: input.typeArguments ?? [],
            arguments: input.arguments ?? []
        )
    }
    
    public static func transferObjects(objects: [ObjectTransactionArgument], address: PureTransactionArgument) -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            objects: objects,
            address: address
        )
    }
    
    public static func splitCoins(coins: ObjectTransactionArgument, amounts: [TransactionArgument]) -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            coin: coins,
            amounts: amounts.map { PureTransactionArgument(argument: $0, type: .u64) }
        )
    }
    
    public static func mergeCoins(destination: ObjectTransactionArgument, sources: [ObjectTransactionArgument]) -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            kind: .mergeCoins,
            destination: destination,
            sources: sources
        )
    }
    
    public static func publish(modules: [[UInt8]], dependencies: [objectId]) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: modules,
            dependencies: dependencies
        )
    }
    
    public static func publish(modules: [String], dependencies: [objectId]) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: modules.compactMap { module in
                guard let result = Data.fromBase64(module) else { return nil }
                return [UInt8](result)
            },
            dependencies: dependencies
        )
    }
    
    public static func upgrade(modules: [[UInt8]], dependencies: [objectId], packageId: objectId, ticket: ObjectTransactionArgument) -> UpgradeTransaction {
        return UpgradeTransaction(
            kind: .upgrade,
            modules: modules,
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }
    
    public static func upgrade(modules: [String], dependencies: [objectId], packageId: objectId, ticket: ObjectTransactionArgument) -> UpgradeTransaction {
        return UpgradeTransaction(
            kind: .upgrade,
            modules: modules.compactMap { module in
                guard let result = Data.fromBase64(module) else { return nil }
                return [UInt8](result)
            },
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }
    
    public static func makeMoveVec(type: String? = nil, objects: [ObjectTransactionArgument]) -> MakeMoveVecTransaction {
        return MakeMoveVecTransaction(
            kind: .makeMoveVec,
            objects: objects,
            type: type
        )
    }
}
