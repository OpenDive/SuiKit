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
    public var transactionBrand: Bool = true
    public var blockData: TransactionBlockDataBuilder

    private var isPreparred: Bool = false

    public static let defaultOfflineLimits: [String: Int] = [
        "maxPureArgumentSize": 16 * 1024,
        "maxTxGas": 50_000_000_000,
        "maxGasObjects": 256,
        "maxTxSizeBytes": 128 * 1024
    ]

    public init(_ blockData: TransactionBlockDataBuilder? = nil) throws {
        self.blockData = try blockData ?? TransactionBlockDataBuilder(
            builder: SerializedTransactionDataBuilder()
        )
    }

    public func setSender(sender: String) throws {
        self.blockData.builder.sender = try AccountAddress.fromHex(sender)
    }

    public func setSenderIfNotSet(sender: String) throws {
        if ((self.blockData.builder.sender) == nil) {
            self.blockData.builder.sender = try AccountAddress.fromHex(sender)
        }
    }

    public func setExpiration(expiration: TransactionExpiration) {
        self.blockData.builder.expiration = expiration
    }

    public func setGasPrice(price: BigInt) {
        self.blockData.builder.gasConfig.price = "\(price)"
    }

    public func setGasPrice(price: Int) {
        self.blockData.builder.gasConfig.price = "\(price)"
    }

    public func setGasBudget(price: BigInt) {
        self.blockData.builder.gasConfig.budget = "\(price)"
    }

    public func setGasBudget(price: Int) {
        self.blockData.builder.gasConfig.budget = "\(price)"
    }

    public func setGasOwner(owner: String) throws {
        self.blockData.builder.gasConfig.owner = try AccountAddress.fromHex(owner)
    }

    public var gas: TransactionArgument {
        return TransactionArgument.gasCoin
    }

    public func setGasPayment(payments: [SuiObjectRef]) throws {
        guard payments.count < TransactionConstants.MAX_GAS_OBJECTS else {
            throw SuiError.gasPaymentTooHigh
        }
        self.blockData.builder.gasConfig.payment = payments
    }

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

    public func object(value: objectId) throws -> TransactionBlockInput {
        let id = try Inputs.getIdFromCallArg(arg: value)
        if let firstMatch = try blockData.builder.inputs.first(where: { input in
            if case .object = input.type,
               case .callArg(let callArg) = input.value,
               case .object(let objArg) = callArg.type {
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

    public func object(value: ObjectArg) throws -> [TransactionBlockInput] {
        let id = try Inputs.getIdFromCallArg(arg: value)
        if let firstMatch = try blockData.builder.inputs.first(where: { input in
            if case .object = input.type,
               let valueEnum = input.value,
               case .callArg(let callArg) = valueEnum,
               case .object(let objectArg) = callArg.type {
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

    public func objectRef(objectArg: ObjectArg) throws -> [TransactionBlockInput] {
        return try self.object(value: objectArg)
    }

    public func shredObjectRef(
        sharedObjectRef: SharedObjectRef
    ) throws -> [TransactionBlockInput] {
        return try self.object(
            value: Inputs.sharedObjectRef(
                sharedObjectRef: sharedObjectRef
            )
        )
    }

    public func pure(value: SuiJsonValue) throws -> TransactionBlockInput {
        return try self.input(type: .pure, value: value)
    }

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

    public func mergeCoin(
        destination: TransactionBlockInput,
        sources: [TransactionBlockInput]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: .mergeCoins(
                Transactions.mergeCoins(
                    destination: .input(destination),
                    sources: sources.map {
                        .input($0)
                    }
                )
            )
        )
    }

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

    public func build(_ provider: SuiProvider, _ onlyTransactionKind: Bool? = nil) async throws -> Data {
        try await self.prepare(BuildOptions(provider: provider, onlyTransactionKind: onlyTransactionKind))
        return try self.blockData.build(onlyTransactionKind: onlyTransactionKind)
    }

    public func getDigest(_ provider: SuiProvider) async throws -> String {
        try await self.prepare(BuildOptions(provider: provider))
        return try self.blockData.getDigest()
    }

    private func isMissingSender(_ onlyTransactionKind: Bool? = nil) -> Bool {
        return
            onlyTransactionKind != nil &&
            !(onlyTransactionKind!) &&
            self.blockData.builder.sender == nil
    }

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
                   case .object(let object) = callArg.type,
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

    private func prepareTransactions(provider: SuiProvider) async throws {
        let blockData = self.blockData.builder

        var moveModulesToResolve: [MoveCallTransaction] = []
        var objectsToResolve: [ObjectsToResolve] = []

        try self.blockData.builder.transactions.forEach { transaction in
            switch transaction {
            case .moveCall(var moveCall):
                try moveCall.addToResolve(
                    list: &moveModulesToResolve,
                    inputs: self.blockData.builder.inputs
                )
            default:
                try transaction.transaction().executeTransaction(
                    objects: &objectsToResolve,
                    inputs: &(self.blockData.builder.inputs)
                )
            }
        }

        if !(moveModulesToResolve.isEmpty) {
            try await moveModulesToResolve.asyncForEach { moveCallTx in
                let moveCallArguments = moveCallTx.target

                let packageId = moveCallArguments.address
                let moduleName = moveCallArguments.module
                let functionName = moveCallArguments.name

                guard let normalized = try await provider.getNormalizedMoveFunction(
                    package: Inputs.normalizeSuiAddress(value: packageId.hex()),
                    moduleName: moduleName,
                    functionName: functionName
                ) else { return }

                let hasTxContext = try normalized.hasTxContext()
                let params = hasTxContext ? normalized.parameters.dropLast() : normalized.parameters
                guard params.count == moveCallTx.arguments.count else { throw SuiError.moveCallSizeDoesNotMatch }

                try params.enumerated().forEach { (idx, param) in
                    let arg = moveCallTx.arguments[idx]

                    switch arg {
                    case .input(let blockInputArgument):
                        let input = blockData.inputs[Int(blockInputArgument.index)]
                        switch input.value {
                        case .callArg: return
                        default: break
                        }
                        guard let inputValue = input.value else { return }
                        let serType = try param.getPureSerializationType(inputValue)
                        if serType != nil {
                            self.blockData.builder.inputs[Int(blockInputArgument.index)].value = .callArg(
                                Input(type: .pure(try Inputs.pure(json: inputValue)))
                            )
                            return
                        }
                        guard param.extractStructTag() != nil || param.kind == "TypeParameter" else { throw SuiError.unknownCallArgType }
                        guard inputValue.kind == .string else { throw SuiError.inputValueIsNotObjectId }

                        switch inputValue {
                        case .string(let string):
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

        if !(objectsToResolve.isEmpty) {
            let dedupedIds = objectsToResolve.map { $0.id }
            let objectChunks = dedupedIds.chunked(into: TransactionConstants.MAX_OBJECTS_PER_FETCH)

            var objects: [SuiObjectResponse] = []

            try await objectChunks.asyncForEach {
                let result = try await provider.getMultiObjects(
                    ids: $0,
                    options: SuiObjectDataOptions(showOwner: true)
                )
                objects.append(contentsOf: result)
            }

            var objectsById: [String : SuiObjectResponse] = [:]
            var resolvedIds: [String: Range<Array<ObjectsToResolve>.Index>.Element] = [:]

            zip(dedupedIds, objects).forEach { (id, object) in
                objectsById[id] = object
            }

            let invalidObjects = objectsById.filter { _, obj in obj.error != nil }.map { key, _ in key }

            guard invalidObjects.isEmpty else { throw SuiError.objectIsInvalid }

            for i in objectsToResolve.indices {
                var idx = i
                var mutable: Bool = false
                var objectToResolve = objectsToResolve[idx]

                if case .callArg(let callArg) = objectToResolve.input.value {
                    mutable = callArg.isMutableSharedObjectInput()
                }

                mutable = mutable || (
                    objectToResolve.normalizedType != nil &&
                    objectToResolve.normalizedType!.extractMutableReference() != nil
                )

                guard let object = objectsById[objectToResolve.id] else { continue }

                if resolvedIds[objectToResolve.id] != nil {
                    idx = resolvedIds[objectToResolve.id]!
                    objectToResolve = objectsToResolve[idx]
                }

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
                for objectToResolve in objectsToResolve {
                    self.blockData.builder.inputs[Int(objectToResolve.input.index)] = objectToResolve.input
                }
            }
        }
    }

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
