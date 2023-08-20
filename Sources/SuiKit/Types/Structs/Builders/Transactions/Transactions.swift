//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable

public struct Transactions {
    public static func moveCall(
        target: String,
        typeArguments: [String]? = nil,
        arguments: [TransactionArgument]? = nil
    ) throws -> MoveCallTransaction {
        return try MoveCallTransaction(
            target: target,
            typeArguments: typeArguments ?? [],
            arguments: arguments ?? []
        )
    }

    public static func transferObjects(
        objects: [TransactionArgument],
        address: TransactionArgument
    ) -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            objects: objects,
            address: address
        )
    }

    public static func splitCoins(
        coins: TransactionArgument,
        amounts: [TransactionArgument]
    ) -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            coin: coins,
            amounts: amounts
        )
    }

    public static func mergeCoins(
        destination: TransactionArgument,
        sources: [TransactionArgument]
    ) -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            destination: destination,
            sources: sources
        )
    }

    public static func publish(
        modules: [[UInt8]],
        dependencies: [objectId]
    ) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: modules,
            dependencies: dependencies
        )
    }

    public static func publish(
        modules: [String],
        dependencies: [objectId]
    ) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: modules.compactMap { module in
                guard let result = Data.fromBase64(module) else { return nil }
                return [UInt8](result)
            },
            dependencies: dependencies
        )
    }

    public static func upgrade(
        modules: [[UInt8]],
        dependencies: [objectId],
        packageId: objectId,
        ticket: TransactionArgument
    ) -> UpgradeTransaction {
        return UpgradeTransaction(
            modules: modules,
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }

    public static func upgrade(
        modules: [String],
        dependencies: [objectId],
        packageId: objectId,
        ticket: TransactionArgument
    ) -> UpgradeTransaction {
        return UpgradeTransaction(
            modules: modules.compactMap { module in
                guard let result = Data.fromBase64(module) else { return nil }
                return [UInt8](result)
            },
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }

    public static func makeMoveVec(
        type: String? = nil,
        objects: [TransactionArgument]
    ) -> MakeMoveVecTransaction {
        return MakeMoveVecTransaction(
            objects: objects,
            type: type
        )
    }
}
