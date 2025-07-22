//
//  Transactions.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
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
    /// Creates a `MoveCallTransaction` instance with a target, optional type arguments, and optional arguments.
    ///
    /// - Parameters:
    ///   - target: A `String` representing the target of the move call.
    ///   - typeArguments: An optional array of `String` representing the type arguments. Defaults to nil.
    ///   - arguments: An optional array of `TransactionArgument` representing the arguments. Defaults to nil.
    /// - Throws: If creating a `MoveCallTransaction` instance fails.
    /// - Returns: An instance of `MoveCallTransaction`.
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

    /// Creates a `TransferObjectsTransaction` instance with given objects and address.
    ///
    /// - Parameters:
    ///   - objects: An array of `TransactionArgument` representing the objects to be transferred.
    ///   - address: A `TransactionArgument` representing the address.
    /// - Returns: An instance of `TransferObjectsTransaction`.
    public static func transferObjects(
        objects: [TransactionArgument],
        address: TransactionArgument
    ) -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            objects: objects,
            address: address
        )
    }

    /// Creates a `SplitCoinsTransaction` instance with given coins and amounts.
    ///
    /// - Parameters:
    ///   - coins: A `TransactionArgument` representing the coins to be split.
    ///   - amounts: An array of `TransactionArgument` representing the amounts.
    /// - Returns: An instance of `SplitCoinsTransaction`.
    public static func splitCoins(
        coins: TransactionArgument,
        amounts: [TransactionArgument]
    ) -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            coin: coins,
            amounts: amounts
        )
    }

    /// Creates a `MergeCoinsTransaction` instance with given destination and sources.
    ///
    /// - Parameters:
    ///   - destination: A `TransactionArgument` representing the destination.
    ///   - sources: An array of `TransactionArgument` representing the sources.
    /// - Returns: An instance of `MergeCoinsTransaction`.
    public static func mergeCoins(
        destination: TransactionArgument,
        sources: [TransactionArgument]
    ) -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            destination: destination,
            sources: sources
        )
    }

    /// Creates a `PublishTransaction` instance with given modules and dependencies.
    ///
    /// - Parameters:
    ///   - modules: An array of `UInt8` arrays representing the modules.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    /// - Throws: If creating a `PublishTransaction` instance fails.
    /// - Returns: An instance of `PublishTransaction`.
    public static func publish(
        modules: [[UInt8]],
        dependencies: [ObjectId]
    ) throws -> PublishTransaction {
        return try PublishTransaction(modules: modules, dependencies: dependencies)
    }

    /// Creates a `PublishTransaction` instance with given modules (as base64 encoded strings) and dependencies.
    ///
    /// - Parameters:
    ///   - modules: An array of base64 encoded `String` representing the modules.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    /// - Throws: If creating a `PublishTransaction` instance fails.
    /// - Returns: An instance of `PublishTransaction`.
    public static func publish(
        modules: [String],
        dependencies: [ObjectId]
    ) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: modules.compactMap { module in
                guard let result = Data.fromBase64(module) else { return nil }
                return [UInt8](result)
            },
            dependencies: dependencies
        )
    }

    /// Creates an `UpgradeTransaction` instance with given modules, dependencies, packageId, and ticket.
    ///
    /// - Parameters:
    ///   - modules: An array of `UInt8` arrays representing the modules.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    ///   - packageId: An `objectId` representing the packageId.
    ///   - ticket: A `TransactionArgument` representing the ticket.
    /// - Returns: An instance of `UpgradeTransaction`.
    public static func upgrade(
        modules: [[UInt8]],
        dependencies: [ObjectId],
        packageId: ObjectId,
        ticket: TransactionArgument
    ) -> UpgradeTransaction {
        return UpgradeTransaction(
            modules: modules,
            dependencies: dependencies,
            packageId: packageId,
            ticket: ticket
        )
    }

    /// Creates an `UpgradeTransaction` instance with given modules (as base64 encoded strings), dependencies, packageId, and ticket.
    ///
    /// - Parameters:
    ///   - modules: An array of base64 encoded `String` representing the modules.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    ///   - packageId: An `objectId` representing the packageId.
    ///   - ticket: A `TransactionArgument` representing the ticket.
    /// - Returns: An instance of `UpgradeTransaction`.
    public static func upgrade(
        modules: [String],
        dependencies: [ObjectId],
        packageId: ObjectId,
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

    /// Creates a `MakeMoveVecTransaction` instance with given type and objects.
    ///
    /// - Parameters:
    ///   - type: An optional `String` representing the type. Defaults to nil.
    ///   - objects: An array of `TransactionArgument` representing the objects.
    /// - Throws: If creating a `MakeMoveVecTransaction` instance fails.
    /// - Returns: An instance of `MakeMoveVecTransaction`.
    public static func makeMoveVec(
        type: String? = nil,
        objects: [TransactionArgument]
    ) throws -> MakeMoveVecTransaction {
        return try MakeMoveVecTransaction(
            objects: objects,
            type: type
        )
    }
}
