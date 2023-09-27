//
//  TransactionBlock.swift
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
import BigInt

public class TransactionBlock {
    /// A boolean value representing the transaction brand.
    public var transactionBrand: Bool = true

    /// An instance of `TransactionBlockDataBuilder` representing the block data.
    public var blockData: TransactionBlockDataBuilder

    /// A boolean value indicating whether the block is prepared or not.
    private var isPreparred: Bool = false

    /// A dictionary containing default offline limits with string keys and integer values.
    public static let defaultOfflineLimits: [String: Int] = [
        "maxPureArgumentSize": 16 * 1024,
        "maxTxGas": 50_000_000_000,
        "maxGasObjects": 256,
        "maxTxSizeBytes": 128 * 1024
    ]

    /// Initializes a new instance of `TransactionBlock`.
    /// - Parameter blockData: An optional `TransactionBlockDataBuilder` instance. Default is `nil`.
    public init(_ blockData: TransactionBlockDataBuilder? = nil) throws {
        self.blockData = try blockData ?? TransactionBlockDataBuilder(
            builder: SerializedTransactionDataBuilder()
        )
    }

    /// Sets the sender of the transaction.
    /// - Parameter sender: A string representing the sender.
    public func setSender(sender: String) throws {
        self.blockData.builder.sender = try AccountAddress.fromHex(sender)
    }

    /// Sets the sender of the transaction if it is not set.
    /// - Parameter sender: A string representing the sender.
    public func setSenderIfNotSet(sender: String) throws {
        if ((self.blockData.builder.sender) == nil) {
            self.blockData.builder.sender = try AccountAddress.fromHex(sender)
        }
    }

    /// Sets the expiration of the transaction.
    /// - Parameter expiration: A `TransactionExpiration` value representing the expiration.
    public func setExpiration(expiration: TransactionExpiration) {
        self.blockData.builder.expiration = expiration
    }

    /// Sets the gas price of the transaction.
    /// - Parameter price: A `BigInt` value representing the gas price.
    public func setGasPrice(price: BigInt) {
        self.blockData.builder.gasConfig.price = "\(price)"
    }

    /// Sets the gas price of the transaction.
    /// - Parameter price: An `Int` value representing the gas price.
    public func setGasPrice(price: Int) {
        self.blockData.builder.gasConfig.price = "\(price)"
    }

    /// Sets the gas budget of the transaction.
    /// - Parameter price: A `BigInt` value representing the gas budget.
    public func setGasBudget(price: BigInt) {
        self.blockData.builder.gasConfig.budget = "\(price)"
    }

    /// Sets the gas budget of the transaction.
    /// - Parameter price: An `Int` value representing the gas budget.
    public func setGasBudget(price: Int) {
        self.blockData.builder.gasConfig.budget = "\(price)"
    }

    /// Sets the gas owner of the transaction.
    /// - Parameter owner: A string representing the gas owner.
    public func setGasOwner(owner: String) throws {
        self.blockData.builder.gasConfig.owner = try AccountAddress.fromHex(owner)
    }

    /// A `TransactionArgument` representing the gas of the transaction.
    public var gas: TransactionArgument {
        return TransactionArgument.gasCoin
    }

    /// Sets the gas payment of the transaction.
    /// - Parameter payments: An array of `SuiObjectRef` representing the gas payments.
    public func setGasPayment(payments: [SuiObjectRef]) throws {
        guard payments.count < TransactionConstants.MAX_GAS_OBJECTS else {
            throw SuiError.gasPaymentTooHigh
        }
        self.blockData.builder.gasConfig.payment = payments
    }

    /// Creates and appends a `TransactionBlockInput` object to the `blockData.builder.inputs`
    /// array and returns it. The type and value of the `TransactionBlockInput` are specified
    /// by the function parameters.
    ///
    /// - Parameters:
    ///   - type: A `ValueType` representing the type of the input.
    ///   - value: An optional `SuiJsonValue` representing the value of the input.
    /// - Throws: Can throw an error if creating a `TransactionBlockInput` fails.
    /// - Returns: A `TransactionBlockInput` object.
    private func input(
        type: ValueType,
        value: SuiJsonValue?
    ) throws -> TransactionBlockInput {
        let index = self.blockData.builder.inputs.count
        let input = TransactionBlockInput(
            index: UInt16(index),
            value: value,
            type: type
        )
        self.blockData.builder.inputs.append(input)
        return input
    }

    /// Creates and returns a `TransactionBlockInput` object for a given object ID.
    ///
    /// - Parameter value: An `objectId` representing the ID of the object.
    /// - Throws: Can throw an error if creating a `TransactionBlockInput` fails.
    /// - Returns: A `TransactionBlockInput` object.
    public func object(value: objectId) throws -> TransactionBlockInput {
        let id = try Inputs.getIdFromCallArg(arg: value)
        if let firstMatch = try blockData.builder.inputs.first(where: { input in
            if 
                case .object = input.type,
                case .callArg(let callArg) = input.value,
                case .object(let objArg) = callArg.inputType
            {
                switch objArg {
                case .shared(let shared):
                    return try Inputs.normalizeSuiAddress(
                        value: shared.objectId
                    ) == id
                case .immOrOwned(let imm):
                    return try Inputs.normalizeSuiAddress(
                        value: imm.ref.objectId
                    ) == id
                }
            }
            return false
        }) {
            return firstMatch
        }
        return try self.input(
            type: .object,
            value: SuiJsonValue.string(value)
        )
    }

    /// Creates and returns an array containing a `TransactionBlockInput` object for a given object argument.
    ///
    /// - Parameter value: An `ObjectArg` representing the argument of the object.
    /// - Throws: Can throw an error if creating a `TransactionBlockInput` fails.
    /// - Returns: An array containing a `TransactionBlockInput` object.
    public func object(value: ObjectArg) throws -> [TransactionBlockInput] {
        let id = try Inputs.getIdFromCallArg(arg: value)
        if let firstMatch = try blockData.builder.inputs.first(where: { input in
            if case .object = input.type,
               let valueEnum = input.value,
               case .callArg(let callArg) = valueEnum,
               case .object(let objectArg) = callArg.inputType {
                switch objectArg {
                case .immOrOwned(let object):
                    return try id == Inputs.normalizeSuiAddress(value: object.ref.objectId)
                case .shared(let object):
                    return try id == Inputs.normalizeSuiAddress(value: object.objectId)
                }
            }
            return false
        }) {
            return [firstMatch]
        }
        let newInput: TransactionBlockInput
        switch value {
        case .immOrOwned(let immOrOwned):
            newInput = try self.input(
                type: .object,
                value: .callArg(
                    Input(
                        type: .object(
                            Inputs.immOrOwnedRef(suiObjectRef: immOrOwned.ref)
                        )
                    )
                )
            )
        case .shared(let sharedArg):
            newInput = try self.input(
                type: .object,
                value: .callArg(
                    Input(
                        type: .object(
                            Inputs.sharedObjectRef(sharedObjectArg: sharedArg)
                        )
                    )
                )
            )
        }
        return [newInput]
    }

    /// A convenience method for creating and returning an array containing a `TransactionBlockInput` object
    /// for a given object argument.
    ///
    /// - Parameter objectArg: An `ObjectArg` representing the argument of the object.
    /// - Throws: Can throw an error if creating a `TransactionBlockInput` fails.
    /// - Returns: An array containing a `TransactionBlockInput` object.
    public func objectRef(objectArg: ObjectArg) throws -> [TransactionBlockInput] {
        return try self.object(value: objectArg)
    }

    /// Creates and returns an array containing a `TransactionBlockInput` object for a given shared object reference.
    ///
    /// - Parameter sharedObjectRef: A `SharedObjectRef` representing the shared object reference.
    /// - Throws: Can throw an error if creating a `TransactionBlockInput` fails.
    /// - Returns: An array containing a `TransactionBlockInput` object.
    public func shredObjectRef(
        sharedObjectRef: SharedObjectRef
    ) throws -> [TransactionBlockInput] {
        return try self.object(
            value: Inputs.sharedObjectRef(
                sharedObjectRef: sharedObjectRef
            )
        )
    }

    /// Creates and returns a `TransactionBlockInput` object with a pure value.
    ///
    /// - Parameter value: A `SuiJsonValue` representing the pure value.
    /// - Throws: Can throw an error if creating a `TransactionBlockInput` fails.
    /// - Returns: A `TransactionBlockInput` object.
    public func pure(value: SuiJsonValue) throws -> TransactionBlockInput {
        return try self.input(type: .pure, value: value)
    }

    /// Appends a `SuiTransaction` object to the `blockData.builder.transactions` array and
    /// returns a `TransactionArgument` object representing the result.
    ///
    /// - Parameter transaction: A `SuiTransaction` object to be added.
    /// - Throws: Can throw an error if the operation fails, for example if result is invalid.
    /// - Returns: A `TransactionArgument` object representing the result of the addition.
    public func add(transaction: SuiTransaction) throws -> TransactionArgument {
        self.blockData.builder.transactions.append(transaction)
        let index = self.blockData.builder.transactions.count
        guard let result = TransactionResult(
            index: UInt16(index - 1)
        )[UInt16(index - 1)] else {
            throw SuiError.invalidResult
        }
        return result
    }

    /// Splits a coin into multiple amounts.
    /// - Parameters:
    ///   - coin: A `TransactionArgument` representing the coin to be split.
    ///   - amounts: An array of `TransactionBlockInput` representing the amounts to split the coin into.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the split coin operation.
    public func splitCoin(
        coin: TransactionArgument,
        amounts: [TransactionBlockInput]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .splitCoins(
                Transactions.splitCoins(
                    coins: coin,
                    amounts: amounts.map {
                        TransactionArgument.input($0)
                    }
                )
            )
        )
    }

    /// Merges multiple source coins into a single destination coin.
    /// - Parameters:
    ///   - destination: A `TransactionArgument` representing the destination coin.
    ///   - sources: An array of `TransactionArgument` representing the source coins.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the merge coin operation.
    public func mergeCoin(
        destination: TransactionArgument,
        sources: [TransactionArgument]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .mergeCoins(
                Transactions.mergeCoins(
                    destination: destination,
                    sources: sources
                )
            )
        )
    }

    /// Publishes modules with given dependencies.
    /// - Parameters:
    ///   - modules: An array of `Data` representing the modules to be published.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the publish operation.
    public func publish(
        modules: [Data],
        dependencies: [objectId]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .publish(
                Transactions.publish(
                    modules: modules.map { [UInt8]($0) },
                    dependencies: dependencies
                )
            )
        )
    }

    /// Publishes modules with given dependencies.
    /// Overloaded function to publish string modules with given dependencies.
    /// - Parameters:
    ///   - modules: An array of `String` representing the string modules to be published.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the publish operation.
    public func publish(
        modules: [String],
        dependencies: [objectId]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .publish(
                Transactions.publish(
                    modules: modules,
                    dependencies: dependencies
                )
            )
        )
    }

    /// Upgrades modules with given dependencies, packageId, and ticket.
    /// - Parameters:
    ///   - modules: An array of `Data` representing the modules to be upgraded.
    ///   - dependencies: An array of `objectId` representing the dependencies.
    ///   - packageId: An `objectId` representing the package ID.
    ///   - ticket: A `TransactionArgument` representing the ticket.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the upgrade operation.
    public func upgrade(
        modules: [Data],
        dependencies: [objectId],
        packageId: objectId,
        ticket: TransactionArgument
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .upgrade(
                Transactions.upgrade(
                    modules: modules.map { [UInt8]($0) },
                    dependencies: dependencies,
                    packageId: packageId,
                    ticket: ticket
                )
            )
        )
    }

    /// Makes a move call with target, optional arguments, and optional type arguments.
    /// - Parameters:
    ///   - target: A `String` representing the target of the move call.
    ///   - arguments: An optional array of `TransactionArgument` representing the arguments of the move call.
    ///   - typeArguments: An optional array of `String` representing the type arguments of the move call.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the move call.
    public func moveCall(
        target: String,
        arguments: [TransactionArgument]? = nil,
        typeArguments: [String]? = nil
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .moveCall(
                Transactions.moveCall(
                    target: target,
                    typeArguments: typeArguments,
                    arguments: arguments
                )
            )
        )
    }

    /// Transfers objects to a specified address.
    /// - Parameters:
    ///   - objects: An array of `TransactionArgument` representing the objects to be transferred.
    ///   - address: A `String` representing the address to transfer objects to.
    /// - Throws: Can throw an error if the addition of transaction fails or if the creation of address fails.
    /// - Returns: A `TransactionArgument` representing the result of the transfer object operation.
    public func transferObject(
        objects: [TransactionArgument],
        address: String
    ) throws -> TransactionArgument {
        let address: SuiJsonValue = .address(try AccountAddress.fromHex(address))
        let addressInput: InputType = .pure(try Inputs.pure(json: address))
        return try self.add(
            transaction: .transferObjects(
                Transactions.transferObjects(
                    objects: objects,
                    address: TransactionArgument.input(
                        self.pure(
                            value: .callArg(
                                Input(type: addressInput)
                            )
                        )
                    )
                )
            )
        )
    }

    /// Makes a Move Vector with the specified type and objects.
    /// - Parameters:
    ///   - type: An optional `String` representing the type of the Move Vector.
    ///   - objects: An array of `TransactionBlockInput` representing the objects of the Move Vector.
    /// - Throws: Can throw an error if the addition of transaction fails.
    /// - Returns: A `TransactionArgument` representing the result of the make Move Vector operation.
    public func makeMoveVec(
        type: String? = nil,
        objects: [TransactionBlockInput]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .makeMoveVec(
                Transactions.makeMoveVec(
                    type: type,
                    objects: objects.map { .input($0) }
                )
            )
        )
    }

    /// Retrieves a configuration value for a specified key.
    /// - Parameters:
    ///   - key: A `LimitsKey` representing the key for which the configuration value needs to be retrieved.
    ///   - buildOptions: A `BuildOptions` object containing the build options including limits and protocolConfig.
    /// - Throws: `SuiError` if the key is not found in limits, protocolConfig is missing, or the attribute is not found.
    /// - Returns: An `Int` representing the configuration value for the specified key.
    public func getConfig(
        key: LimitsKey,
        buildOptions: BuildOptions
    ) throws -> Int {
        // If limits contains the key, return its value.
        if let keyNumber = buildOptions.limits?[key.rawValue] {
            guard let keyNumber else { throw SuiError.cannotFindKeyNumber }
            return keyNumber
        }

        // Handle the case where protocolConfig is nil.
        if buildOptions.protocolConfig == nil {
            guard let defaultValue = Self.defaultOfflineLimits[key.rawValue] else {
                throw SuiError.cannotFindProtocolConfig
            }
            return defaultValue
        }

        // Unwrap protocolConfig's attributes for the given key.
        guard let attribute = buildOptions.protocolConfig?.attributes[key.rawValue] else {
            throw SuiError.cannotFindProtocolConfig
        }

        switch attribute {
        case .f64(let f64): return Int(f64)!
        case .u32(let u32): return Int(u32)!
        case .u64(let u64): return Int(u64)!
        default:
            throw SuiError.cannotFindAttribute
        }
    }

    /// Builds a block with the specified provider and optional transaction kind.
    /// - Parameters:
    ///   - provider: A `SuiProvider` representing the provider to build the block with.
    ///   - onlyTransactionKind: An optional `Bool` representing whether only transaction kind should be considered while building.
    /// - Throws: Can throw an error if preparation or block building fails.
    /// - Returns: A `Data` object representing the built block.
    public func build(_ provider: SuiProvider, _ onlyTransactionKind: Bool? = nil) async throws -> Data {
        try await self.prepare(BuildOptions(provider: provider, onlyTransactionKind: onlyTransactionKind))
        return try self.blockData.build(onlyTransactionKind: onlyTransactionKind)
    }

    /// Computes the digest of the block with the specified provider.
    /// - Parameters:
    ///   - provider: A `SuiProvider` representing the provider to compute the digest with.
    /// - Throws: Can throw an error if preparation or digest computation fails.
    /// - Returns: A `String` representing the digest of the block.
    public func getDigest(_ provider: SuiProvider) async throws -> String {
        try await self.prepare(BuildOptions(provider: provider))
        return try self.blockData.getDigest()
    }

    /// Determines whether the sender is missing considering the specified transaction kind.
    /// - Parameters:
    ///   - onlyTransactionKind: An optional `Bool` representing whether only transaction kind should be considered.
    /// - Returns: A `Bool` indicating whether the sender is missing.
    private func isMissingSender(_ onlyTransactionKind: Bool? = nil) -> Bool {
        return
            onlyTransactionKind != nil &&
            !(onlyTransactionKind!) &&
            self.blockData.builder.sender == nil
    }

    /// Prepares gas payment for transactions.
    /// - Parameters:
    ///   - provider: A `SuiProvider` instance used to obtain necessary information to prepare gas payment.
    ///   - onlyTransactionKind: An optional `Bool`. If true, it prepares gas payment only for a specific kind of transaction.
    /// - Throws: Can throw `SuiError.senderIsMissing` if the sender is missing, `SuiError.gasOwnerCannotBeFound` if the gas owner cannot be found, and `SuiError.ownerDoesNotHavePaymentCoins` if the owner does not have payment coins.
    /// - Note: This method is asynchronous and can be awaited.
    private func prepareGasPayment(
        provider: SuiProvider,
        onlyTransactionKind: Bool? = nil
    ) async throws {
        if isMissingSender(onlyTransactionKind) {
            throw SuiError.senderIsMissing
        }

        if onlyTransactionKind == true || self.blockData.builder.gasConfig.payment != nil {
            return
        }

        guard let gasOwner = self.blockData.builder.gasConfig.owner?.hex() ?? self.blockData.builder.sender?.hex() else {
            throw SuiError.gasOwnerCannotBeFound
        }

        let coins = try await provider.getCoins(
            account: gasOwner,
            coinType: "0x2::sui::SUI"
        )

        let filteredCoins = coins.data.filter { coin in
            return !self.blockData.builder.inputs.contains { input in
                if case .callArg(let callArg) = input.value,
                   case .object(let object) = callArg.inputType,
                   case .immOrOwned(let imm) = object {
                    return coin.coinObjectId == imm.ref.objectId
                }
                return false
            }
        }

        let range = 0..<min(TransactionConstants.MAX_GAS_OBJECTS, filteredCoins.count)
        let paymentCoins = filteredCoins[range].map { coin in
            SuiObjectRef(
                objectId: coin.coinObjectId,
                version: coin.version,
                digest: coin.digest
            )
        }

        guard !paymentCoins.isEmpty else {
            throw SuiError.ownerDoesNotHavePaymentCoins
        }

        try self.setGasPayment(payments: paymentCoins)
    }

    /// Prepares gas price for transactions.
    /// - Parameters:
    ///   - provider: A `SuiProvider` instance used to obtain necessary information to prepare gas price.
    ///   - onlyTransactionKind: An optional `Bool`. If true, it prepares gas price only for a specific kind of transaction.
    /// - Throws: Can throw `SuiError.senderIsMissing` if the sender is missing.
    /// - Note: This method is asynchronous and can be awaited.
    private func prepareGasPrice(
        provider: SuiProvider,
        onlyTransactionKind: Bool? = nil
    ) async throws {
        if self.isMissingSender(onlyTransactionKind) {
            throw SuiError.senderIsMissing
        }
        self.setGasPrice(
            price: BigInt(
                try await provider.getGasPrice()
            )
        )
    }

    /// Prepares transactions by resolving move modules and objects, and updating the block data builder with the resolved information.
    /// - Parameter provider: A `SuiProvider` instance used to obtain necessary information to prepare transactions.
    /// - Throws: Various `SuiError` errors can be thrown based on different failure scenarios, such as `SuiError.moveCallSizeDoesNotMatch` when move call size does not match, `SuiError.unknownCallArgType` when the call argument type is unknown, and `SuiError.inputValueIsNotObjectId` when the input value is not object ID, and `SuiError.objectIsInvalid` when an object is invalid.
    /// - Note: This method is asynchronous and can be awaited.
    private func prepareTransactions(provider: SuiProvider) async throws {
        // Retrieve the blockData from the builder property of the object
        let blockData = self.blockData.builder

        // Initialize arrays to store move modules and objects that need to be resolved
        var moveModulesToResolve: [MoveCallTransaction] = []
        var objectsToResolve: [ObjectsToResolve] = []

        // Loop through each transaction in the blockData's transactions to resolve move modules and objects
        try self.blockData.builder.transactions.forEach { transaction in
            switch transaction {
            case .moveCall(var moveCall):
                // If the transaction is of type moveCall, add to the list of move modules to resolve
                try moveCall.addToResolve(
                    list: &moveModulesToResolve,
                    inputs: self.blockData.builder.inputs
                )
            default:
                // Execute other types of transactions and add any objects to the list of objects to resolve
                try transaction.transaction().executeTransaction(
                    objects: &objectsToResolve,
                    inputs: &(self.blockData.builder.inputs)
                )
            }
        }

        // If there are move modules to resolve, resolve each asynchronously
        if !(moveModulesToResolve.isEmpty) {
            try await moveModulesToResolve.asyncForEach { moveCallTx in
                // Extract moveCallArguments for further processing
                let moveCallArguments = moveCallTx.target

                // Extract packageId, moduleName, and functionName from the moveCallArguments
                let packageId = moveCallArguments.address
                let moduleName = moveCallArguments.module
                let functionName = moveCallArguments.name

                // Get the normalized Move function from the provider
                guard let normalized = try await provider.getNormalizedMoveFunction(
                    package: Inputs.normalizeSuiAddress(value: packageId.hex()),
                    moduleName: moduleName,
                    functionName: functionName
                ) else { return }

                // Determine if the normalized function has a transaction context
                let hasTxContext = try normalized.hasTxContext()

                // Obtain parameters of the normalized function, dropping the last one if it has a transaction context
                let params = hasTxContext ? normalized.parameters.dropLast() : normalized.parameters
                guard params.count == moveCallTx.arguments.count else { throw SuiError.moveCallSizeDoesNotMatch }

                // Validate and process the arguments of the moveCall transaction
                try params.enumerated().forEach { (idx, param) in
                    let arg = moveCallTx.arguments[idx]

                    switch arg {
                    case .input(let blockInputArgument):
                        // Handle the .input case by validating the input and modifying the blockData if necessary
                        let input = blockData.inputs[Int(blockInputArgument.index)]
                        guard let inputValue = input.value else { return }
                        let serType = try param.getPureSerializationType(inputValue)
                        if serType != nil {
                            // If serialization type exists, update the input value in the blockData
                            self.blockData.builder.inputs[Int(blockInputArgument.index)].value = .callArg(
                                Input(type: .pure(try Inputs.pure(json: inputValue)))
                            )
                            return
                        }
                        // Handle errors and edge cases related to input value and parameter types
                        guard param.extractStructTag() != nil || param.kind == "TypeParameter" else { throw SuiError.unknownCallArgType }
                        guard inputValue.kind == .string else { throw SuiError.inputValueIsNotObjectId }

                        switch inputValue {
                        case .string(let string):
                            // Append the object to resolve to the objectsToResolve array
                            objectsToResolve.append(
                                ObjectsToResolve(
                                    id: string,
                                    input: input,
                                    normalizedType: param
                                )
                            )
                        default:
                            throw SuiError.inputValueIsNotObjectId
                        }
                    default: return
                    }
                }
            }
        }

        // If there are objects to resolve, resolve each object and handle errors and special cases
        if !(objectsToResolve.isEmpty) {
            // Chunk the object IDs to fetch and initialize an array to store the fetched objects
            let dedupedIds = objectsToResolve.map { $0.id }
            let objectChunks = dedupedIds.chunked(into: TransactionConstants.MAX_OBJECTS_PER_FETCH)
            var objects: [SuiObjectResponse] = []

            // Fetch objects in chunks asynchronously and append them to the objects array
            try await objectChunks.asyncForEach {
                let result = try await provider.getMultiObjects(
                    ids: $0,
                    options: SuiObjectDataOptions(showOwner: true)
                )
                objects.append(contentsOf: result)
            }

            // Resolve the fetched objects and manage the object IDs and references
            var objectsById: [String : SuiObjectResponse] = [:]
            var resolvedIds: [String: Range<Array<ObjectsToResolve>.Index>.Element] = [:]
            zip(dedupedIds, objects).forEach { (id, object) in
                objectsById[id] = object
            }

            // Handle invalid objects and throw an error if any are found
            let invalidObjects = objectsById.filter { _, obj in obj.error != nil }.map { key, _ in key }
            guard invalidObjects.isEmpty else { throw SuiError.objectIsInvalid }

            // Process each object to resolve and update the blockData and related structures accordingly
            for i in objectsToResolve.indices {
                var idx = i
                var mutable: Bool = false
                var objectToResolve = objectsToResolve[idx]

                if case .callArg(let callArg) = objectToResolve.input.value {
                    mutable = callArg.isMutableSharedObjectInput()
                }

                // Set mutable based on the normalized type of the object to resolve
                mutable = mutable || (
                    objectToResolve.normalizedType != nil &&
                    objectToResolve.normalizedType!.extractMutableReference() != nil
                )

                guard let object = objectsById[objectToResolve.id] else { continue }

                if resolvedIds[objectToResolve.id] != nil {
                    idx = resolvedIds[objectToResolve.id]!
                    objectToResolve = objectsToResolve[idx]
                }

                // Update the input value in the objectsToResolve array based on the initial shared version or object reference
                guard let initialSharedVersion = object.getSharedObjectInitialVersion() else {
                    guard let objRef = object.getObjectReference() else { continue }
                    objectsToResolve[idx].input.value = .callArg(
                        Input(
                            type: .object(
                                .immOrOwned(
                                    ImmOrOwned(ref: objRef)
                                )
                            )
                        )
                    )
                    resolvedIds[objectToResolve.id] = idx
                    continue
                }

                objectsToResolve[idx].input.value = .callArg(
                    Input(
                        type: .object(
                            .shared(
                                SharedObjectArg(
                                    objectId: objectsToResolve[idx].id,
                                    initialSharedVersion: UInt64(initialSharedVersion),
                                    mutable: mutable
                                )
                            )
                        )
                    )
                )
                resolvedIds[objectToResolve.id] = idx
            }

            // Update the blockData inputs and transactions based on the resolved objects and IDs
            if resolvedIds.count != objectsToResolve.count {
                self.blockData.builder.inputs = []
                for object in objectsToResolve {
                    self.blockData.builder.inputs.append(object.input)
                }

                for (idx, transaction) in self.blockData.builder.transactions.enumerated() {
                    if case .moveCall(var moveCall) = transaction {
                        for (idxArgument, argument) in moveCall.arguments.enumerated() {
                            for object in objectsToResolve {
                                if case .input(let txInput) = argument,
                                   object.input.value == txInput.value,
                                   object.input.index != txInput.index {
                                    moveCall.arguments[idxArgument] = .input(object.input)
                                    self.blockData.builder.transactions[idx] = .moveCall(moveCall)
                                }
                            }
                        }
                    }
                }
            } else {
                // If the count of resolved IDs matches the count of objects to resolve, simply update the blockData inputs
                for objectToResolve in objectsToResolve {
                    self.blockData.builder.inputs[Int(objectToResolve.input.index)] = objectToResolve.input
                }
            }
        }
    }

    /// Prepares the transaction block with the provided build options.
    /// - Parameter optionsPassed: An instance of `BuildOptions` that contains the options passed for preparing the transaction block.
    /// - Throws: `SuiError.providerNotFound` if the provider is not found in the options, `SuiError.failedDryRun` if the dry run of the transaction block fails, and other errors depending on the failure scenarios in the internal methods called.
    /// - Note: This method is asynchronous and can be awaited.
    /// The method will return immediately if the transaction block is already prepared (`self.isPreparred` is true).
    /// If `protocolConfig` and `limits` are not provided in the options, they are fetched asynchronously from the provider.
    /// The method also prepares gas price and transactions using internal methods and handles gas payment and budget computation based on the `onlyTransactionKind` option.
    private func prepare(_ optionsPassed: BuildOptions) async throws {
        guard !(self.isPreparred) else { return }

        var options: BuildOptions = optionsPassed

        guard let provider = options.provider else {
            throw SuiError.providerNotFound
        }

        if options.protocolConfig == nil && options.limits == nil {
            options.protocolConfig = try await provider.getProtocolConfig()
        }

        try await self.prepareGasPrice(provider: provider, onlyTransactionKind: options.onlyTransactionKind ?? false)
        try await self.prepareTransactions(provider: provider)

        if (options.onlyTransactionKind == nil) || (options.onlyTransactionKind != nil && !(options.onlyTransactionKind!)) {
            let onlyTransactionKind = options.onlyTransactionKind

            try await self.prepareGasPayment(provider: provider, onlyTransactionKind: onlyTransactionKind)

            if self.blockData.builder.gasConfig.budget == nil {
                let blockData = self.blockData

                var gasConfig = blockData.builder.gasConfig

                gasConfig.budget = String(try self.getConfig(key: LimitsKey.maxTxGas, buildOptions: options))
                gasConfig.payment = []

                let txBlockDataBuilder = try TransactionBlockDataBuilder(
                    builder: SerializedTransactionDataBuilder(gasConfig: gasConfig)
                )

                let dryRunResult = try await provider.dryRunTransactionBlock(
                    transactionBlock: [UInt8](blockData.build(overrides: txBlockDataBuilder))
                )

                guard dryRunResult.effects?.status.status != .failure else {
                    throw SuiError.failedDryRun
                }

                let safeOverhead = TransactionConstants.GAS_SAFE_OVERHEAD * (
                    Int(blockData.builder.gasConfig.price ?? "1")!
                )

                let baseComputationCostWithOverhead = 
                    (Int(dryRunResult.effects?.gasUsed.computationCost ?? "0")!) +
                    safeOverhead

                let gasBudget =
                    baseComputationCostWithOverhead +
                    (Int(dryRunResult.effects?.gasUsed.storageCost ?? "0")!) -
                    (Int(dryRunResult.effects?.gasUsed.storageRebate ?? "0")!)

                self.setGasBudget(
                    price: gasBudget > baseComputationCostWithOverhead ?
                        BigInt(gasBudget) :
                        BigInt(baseComputationCostWithOverhead)
                )
            }
        }
        self.isPreparred = true
    }
}
