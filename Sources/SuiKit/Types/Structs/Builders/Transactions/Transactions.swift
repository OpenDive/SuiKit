//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable

public struct Transactions {
    public func moveCall(input: MoveCallTransactionInput) -> MoveCallTransaction {
        return MoveCallTransaction(
            kind: "MoveCall",
            target: input.target,
            typeArguments: input.typeArguments ?? [],
            arguments: input.arguments ?? []
        )
    }
    
    public func transferObjects(objects: [ObjectTransactionArgument], address: PureTransactionArgument) -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            kind: "TransferObject",
            objects: objects,
            address: address
        )
    }
    
    public func splitCoins(coins: ObjectTransactionArgument, amounts: [TransactionArgument]) -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            kind: "SplitCoins",
            coin: coins,
            amounts: amounts.map { PureTransactionArgument(argument: $0, type: "u64") }
        )
    }
    
    public func mergeCoins(destination: ObjectTransactionArgument, sources: [ObjectTransactionArgument]) -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            kind: "MergeCoins",
            destination: destination,
            sources: sources
        )
    }
    
    public func publish(modules: [[UInt8]], dependencies: [objectId]) -> PublishTransaction {
        return PublishTransaction(
            kind: "Publish",
            modules: modules,
            dependencies: dependencies
        )
    }
    
    public func publish(modules: [String], dependencies: [objectId]) -> PublishTransaction {
        return PublishTransaction(
            kind: "Publish",
            modules: modules.map { B64.fromB64(sBase64: $0) },
            dependencies: dependencies
        )
    }
    
    public func upgrade(modules: [[UInt8]], dependencies: [objectId], packageId: objectId, ticket: ObjectTransactionArgument) -> UpgradeTransaction {
        return UpgradeTransaction(
            kind: "Upgrade",
            modules: modules,
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }
    
    public func upgrade(modules: [String], dependencies: [objectId], packageId: objectId, ticket: ObjectTransactionArgument) -> UpgradeTransaction {
        return UpgradeTransaction(
            kind: "Upgrade",
            modules: modules.map { B64.fromB64(sBase64: $0) },
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }
    
    public func makeMoveVec(type: String? = nil, objects: ObjectTransactionArgument) -> MakeMoveVecTransaction {
        return MakeMoveVecTransaction(
            kind: "MakeMoveVec",
            objects: objects,
            type: type
        )
    }
}
