//
//  Transactions.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

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
