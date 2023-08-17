//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import BigInt

public class TransactionResult {
    let transactionArgument: TransactionArgument
    var nestedResults: [TransactionArgument]
    
    public init(index: UInt16) {
        self.transactionArgument = TransactionArgument.result(
            Result(index: index)
        )
        self.nestedResults = []
    }
    
    public func nestedResultFor(_ resultIndex: UInt16) -> TransactionArgument? {
        if nestedResults.indices.contains(Int(resultIndex)) {
            return nestedResults[Int(resultIndex)]
        } else {
            switch transactionArgument {
            case .result(let result):
                let nestedResult = TransactionArgument.nestedResult(
                    NestedResult(
                        index: result.index,
                        resultIndex: resultIndex
                    )
                )
                nestedResults.append(nestedResult)
                return nestedResult
            default:
                return nil
            }
        }
    }
    
    public subscript(index: UInt16) -> TransactionArgument? {
        guard index > 0 else { return self.transactionArgument }
        return nestedResultFor(index)
    }
}

public let defaultOfflineLimits: [String: Int] = [
    "maxPureArgumentSize": 16 * 1024,
    "maxTxGas": 50_000_000_000,
    "maxGasObjects": 256,
    "maxTxSizeBytes": 128 * 1024
]

public struct TransactionConstants {
    public static let MAX_GAS_OBJECTS = 256
    public static let MAX_GAS = 50_000_000_000
    public static let GAS_SAFE_OVERHEAD = 1_000
    public static let MAX_OBJECTS_PER_FETCH = 50
}

public struct BuildOptions {
    public var provider: SuiProvider?
    public var onlyTransactionKind: Bool?
    public var limits: Limits?
    public var protocolConfig: ProtocolConfig?
    
    public init(provider: SuiProvider? = nil, onlyTransactionKind: Bool? = nil, limits: Limits? = nil, protocolConfig: ProtocolConfig? = nil) {
        self.provider = provider
        self.onlyTransactionKind = onlyTransactionKind
        self.limits = limits
        self.protocolConfig = protocolConfig
    }
}

public struct TransactionBlock {
    public var transactionBrand: Bool = true
    public var blockData: TransactionBlockDataBuilder
    
    private var isPreparred: Bool = false
    
    public init(_ blockData: TransactionBlockDataBuilder? = nil) throws {
        self.blockData = try blockData ?? TransactionBlockDataBuilder(
            serializedTransactionDataBuilder: SerializedTransactionDataBuilder()
        )
    }
    
    public static func isInstance(_ obj: Any) -> Bool {
        guard let obj = obj as? TransactionBlock else { return false }
        return obj.transactionBrand
    }
    
    public static func fromKind(serialized: Data) throws -> TransactionBlock {
        var tx = try TransactionBlock()
        tx.blockData = try TransactionBlockDataBuilder.fromKindBytes(
            bytes: serialized
        )
        return tx
    }
    
    public static func fromKind(serialized: String) throws -> TransactionBlock {
        guard let bytes = Data.fromBase64(serialized) else { throw SuiError.notImplemented }
        var tx = try TransactionBlock()
        tx.blockData = try TransactionBlockDataBuilder.fromKindBytes(
            bytes: bytes
        )
        return tx
    }
    
    public static func from(serialized: Data) throws -> TransactionBlock {
        return try TransactionBlock(
            TransactionBlockDataBuilder.fromBytes(bytes: serialized)
        )
    }
    
    mutating public func setSender(sender: SuiAddress) {
        self.blockData.serializedTransactionDataBuilder.sender = sender
    }
    
    mutating public func setSenderIfNotSet(sender: SuiAddress) {
        if ((self.blockData.serializedTransactionDataBuilder.sender) == nil) {
            self.blockData.serializedTransactionDataBuilder.sender = sender
        }
    }
    
    mutating public func setExpiration(expiration: TransactionExpiration) {
        self.blockData.serializedTransactionDataBuilder.expiration = expiration
    }
    
    mutating public func setGasPrice(price: BigInt) {
        self.blockData.serializedTransactionDataBuilder.gasConfig.price = "\(price)"
    }
    
    mutating public func setGasPrice(price: Int) {
        self.blockData.serializedTransactionDataBuilder.gasConfig.price = "\(price)"
    }
    
    mutating public func setGasBudget(price: BigInt) {
        self.blockData.serializedTransactionDataBuilder.gasConfig.budget = "\(price)"
    }
    
    mutating public func setGasBudget(price: Int) {
        self.blockData.serializedTransactionDataBuilder.gasConfig.budget = "\(price)"
    }
    
    mutating public func setGasOwner(owner: String) throws {
        self.blockData.serializedTransactionDataBuilder.gasConfig.owner = try ED25519PublicKey(hexString: owner)
    }
    
    public var gas: TransactionArgument {
        return TransactionArgument.gasCoin
    }
    
    mutating public func setGasPayment(payments: [SuiObjectRef]) throws {
        guard payments.count < TransactionConstants.MAX_GAS_OBJECTS else {
            throw SuiError.notImplemented
        }
        self.blockData.serializedTransactionDataBuilder.gasConfig.payment = payments
    }
    
    mutating private func input(type: ValueType, value: SuiJsonValue?) throws -> TransactionBlockInput {
        let index = self.blockData.serializedTransactionDataBuilder.inputs.count
        let input = TransactionBlockInput(
            index: UInt16(index),
            value: value,
            type: type
        )
        self.blockData.serializedTransactionDataBuilder.inputs.append(input)
        return input
    }
    
    public mutating func object(value: objectId) throws -> TransactionBlockInput {
        let id = try getIdFromCallArg(arg: value)
        let blockData = self.blockData
        let inserted = try blockData.serializedTransactionDataBuilder.inputs.filter { input in
            if input.type == .object {
                guard let valueEnum = input.value else { return false }
                switch valueEnum {
                case .callArg(let callArg):
                    switch callArg.type {
                    case .pure:
                        return false
                    case .immOrOwned(let object):
                        return id == object.immOrOwned.objectId
                    case .sharedObject(let object):
                        return id == object.objectId
                    }
                case .input(let input):
                    switch input.type {
                    case .pure:
                        return false
                    case .immOrOwned(let object):
                        return id == object.immOrOwned.objectId
                    case .sharedObject(let object):
                        return id == object.objectId
                    }
                case .string(let str):
                    return try getIdFromCallArg(arg: str) == id
                default:
                    return false
                }
            }
            return false
        }
        if !inserted.isEmpty {
            return inserted[0]
        }

        return try self.input(
            type: .object,
            value: SuiJsonValue.string(value)
        )
    }
    
    public mutating func object(value: ObjectCallArg) throws -> [TransactionBlockInput] {
        let id = try getIdFromCallArg(arg: value)
        let blockData = self.blockData
        let inserted = blockData.serializedTransactionDataBuilder.inputs.filter { input in
            if input.type == .object {
                guard let valueEnum = input.value else { return false }
                switch valueEnum {
                case .callArg(let callArg):
                    switch callArg.type {
                    case .pure:
                        return false
                    case .immOrOwned(let object):
                        return id == object.immOrOwned.objectId
                    case .sharedObject(let object):
                        return id == object.objectId
                    }
                default:
                    return false
                }
            }
            
            return false
        }
        
        if !inserted.isEmpty {
            return inserted
        }
        
        switch value.object {
        case .immOrOwned(let immOrOwned):
            return [
                try self.input(
                    type: .object,
                    value: .callArg(
                        ObjectCallArg(
                            object: .immOrOwned(immOrOwned),
                            type: .immOrOwned(immOrOwned)
                        )
                    )
                )
            ]
        case .shared(let sharedArg):
            let sharedObj = sharedArg.shared
            return [
                try self.input(
                    type: .object,
                    value: .callArg(
                        ObjectCallArg(
                            object: .shared(sharedArg),
                            type: .sharedObject(sharedObj)
                        )
                    )
                )
            ]
        }
    }
    
    public mutating func objectRef(objectRef: SuiObjectRef) throws -> [TransactionBlockInput] {
        return try self.object(value: Inputs.objectRef(suiObjectRef: objectRef))
    }
    
    public mutating func shredObjectRef(sharedObjectRef: SharedObjectRef) throws -> [TransactionBlockInput] {
        return try self.object(value: Inputs.sharedObjectRef(sharedObjectRef: sharedObjectRef))
    }
    
    public mutating func pure(value: SuiJsonValue) throws -> TransactionBlockInput {
        return try self.input(type: .pure, value: value)
    }
    
    public mutating func add(transaction: any TransactionProtocol, name: SuiTransactionKindName) throws -> TransactionArgument {
        self.blockData.serializedTransactionDataBuilder.transactions.append(
            SuiTransaction(suiTransaction: transaction, name: name)
        )
        let index = self.blockData.serializedTransactionDataBuilder.transactions.count
        guard let result = TransactionResult(index: UInt16(index - 1))[UInt16(index - 1)] else {
            throw SuiError.invalidResult
        }
        return result
    }
    
    public mutating func splitCoin(coin: TransactionArgument, amounts: [TransactionBlockInput]) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.splitCoins(
                coins: ObjectTransactionArgument(
                    argument: coin
                ),
                amounts: amounts.map { TransactionArgument.input($0) }
            ),
            name: .splitCoins
        )
    }
    
    public mutating func mergeCoin(destination: TransactionBlockInput, sources: [TransactionBlockInput]) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.mergeCoins(
                destination: ObjectTransactionArgument(
                    argument: TransactionArgument.input(destination)
                ),
                sources: sources.map {
                    ObjectTransactionArgument(
                        argument: TransactionArgument.input($0)
                    )
                }
            ),
            name: .mergeCoins
        )
    }
    
    public mutating func publish(
        modules: [Data],
        dependencies: [objectId]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.publish(
                modules: modules.map { [UInt8]($0) },
                dependencies: dependencies
            ),
            name: .publish
        )
    }
    
    public mutating func publish(
        modules: [String],
        dependencies: [objectId]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.publish(
                modules: modules,
                dependencies: dependencies
            ),
            name: .publish
        )
    }
    
    public mutating func upgrade(
        modules: [Data],
        dependencies: [objectId],
        packageId: objectId,
        ticket: TransactionArgument
    ) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.upgrade(
                modules: modules.map { [UInt8]($0) },
                dependencies: dependencies,
                packageId: packageId,
                ticket: ObjectTransactionArgument(
                    argument: ticket
                )
            ),
            name: .upgrade
        )
    }
    
    public mutating func moveCall(target: String, arguments: [TransactionArgument]? = nil, typeArguments: [String]? = nil) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.moveCall(
                input: MoveCallTransactionInput(
                    target: target,
                    arguments: arguments,
                    typeArguments: typeArguments
                )
            ),
            name: .moveCall
        )
    }
    
    public mutating func transferObject(objects: [TransactionArgument], address: String) throws -> TransactionArgument {
        return try self.add(
            transaction: Transactions.transferObjects(
                objects: objects.map {
                    ObjectTransactionArgument(
                        argument: $0
                    )
                },
                address: PureTransactionArgument(
                    argument: TransactionArgument.input(
                        self.pure(
                            value: .callArg(
                                PureCallArg(
                                    pure: [UInt8](try address.replacingOccurrences(of: "0x", with: "").stringToBytes())
                                )
                            )
                        )
                    ),
                    type: .address
                )
            ),
            name: .transferObjects
        )
    }
    
    public mutating func makeMoveVec(type: String? = nil, objects: [TransactionBlockInput]) throws -> TransactionArgument {
        try self.add(
            transaction: Transactions.makeMoveVec(
                type: type,
                objects: objects.map {
                    ObjectTransactionArgument(
                        argument: TransactionArgument.input($0)
                    )
                }
            ),
            name: .makeMoveVec
        )
    }
    
    public func getConfig(key: LimitsKey, buildOptions: BuildOptions) throws -> Int {
        if let limits = buildOptions.limits, let keyNumberWrapped = limits[key.rawValue] {
            if let keyNumber = keyNumberWrapped {
                return keyNumber
            }
        }
        
        if buildOptions.protocolConfig == nil {
            if let defaultValue = defaultOfflineLimits[key.rawValue] {
                return defaultValue
            }
        }
        
        if buildOptions.protocolConfig!.attributes[key.rawValue] == nil {
            throw SuiError.notImplemented
        }
        
        let attribute = buildOptions.protocolConfig!.attributes[key.rawValue]!
        
        if attribute == nil {
            throw SuiError.notImplemented
        }
        
        switch attribute! {
        case .f64(let f64): return Int(f64)!
        case .u32(let u32): return Int(u32)!
        case .u64(let u64): return Int(u64)!
        }
    }
    
    public mutating func build(_ provider: SuiProvider, _ onlyTransactionKind: Bool? = nil) async throws -> Data {
        try await self.prepare(BuildOptions(provider: provider, onlyTransactionKind: onlyTransactionKind))
        return try self.blockData.build(onlyTransactionKind: onlyTransactionKind)
    }
    
    public mutating func getDigest(_ provider: SuiProvider) async throws -> String {
        try await self.prepare(BuildOptions(provider: provider))
        return try self.blockData.getDigest()
    }
    
    private mutating func prepareGasPayment(provider: SuiProvider, onlyTransactionKind: Bool? = nil) async throws {
        if self.isMissingSender(onlyTransactionKind) {
            throw SuiError.notImplemented
        }
        
        if (onlyTransactionKind != nil && onlyTransactionKind!) || self.blockData.serializedTransactionDataBuilder.gasConfig.payment != nil {
            return
        }
        
        guard let gasOwner =
                self.blockData.serializedTransactionDataBuilder.gasConfig.owner?.hex() ??
                self.blockData.serializedTransactionDataBuilder.sender
        else {
            throw SuiError.notImplemented
        }
        
        let coins = try await provider.getCoins(
            gasOwner,
            "0x2::sui::SUI"
        )
        let filteredCoins = coins.data.filter { coin in
            let matchingInput = self.blockData.serializedTransactionDataBuilder.inputs.filter { input in
                if let value = input.value {
                    switch value {
                    case .callArg(let callArg):
                        switch callArg.type {
                        case .immOrOwned(let immOrOwned):
                            return coin.coinObjectId == immOrOwned.immOrOwned.objectId
                        default:
                            return false
                        }
                    case .input(let input):
                        switch input.type {
                        case .immOrOwned(let immOrOwned):
                            return coin.coinObjectId == immOrOwned.immOrOwned.objectId
                        default:
                            return false
                        }
                    default:
                        return false
                    }
                }
                return false
            }
            return matchingInput.isEmpty
        }
        
        let paymentCoins = filteredCoins[
            0..<min(TransactionConstants.MAX_GAS_OBJECTS, filteredCoins.count)
        ].map { coin in
            SuiObjectRef(
                objectId: coin.coinObjectId,
                version: UInt64(coin.version) ?? UInt64(0),
                digest: coin.digest
            )
        }
        
        guard !paymentCoins.isEmpty else {
            throw SuiError.notImplemented
        }
        
        try self.setGasPayment(payments: paymentCoins)
    }
    
    private mutating func prepareGasPrice(provider: SuiProvider, onlyTransactionKind: Bool? = nil) async throws {
        if self.isMissingSender(onlyTransactionKind) {
            throw SuiError.notImplemented
        }
        
        self.setGasPrice(
            price: BigInt(
                try await provider.getGasPrice()
            )
        )
    }
    
    private mutating func prepareTransactions(provider: SuiProvider) async throws {
        let blockData = self.blockData.serializedTransactionDataBuilder

        var moveModulesToResolve: [MoveCallTransaction] = []

        var objectsToResolve: [ObjectsToResolve] = []

        try blockData.transactions.forEach { transaction in
            if transaction.name == .moveCall {
                try (transaction.suiTransaction as! MoveCallTransaction).addToResolve(
                    list: &moveModulesToResolve,
                    inputs: blockData.inputs
                )
            } else {
                try transaction.suiTransaction.executeTransaction(objects: &objectsToResolve, inputs: &(blockData.inputs))
            }
        }

        if !(moveModulesToResolve.isEmpty) {
            try await moveModulesToResolve.asyncForEach { moveCallTx in
                let moveCallArguments = try moveCallTx.target.toModule()
                
                let packageId = moveCallArguments.address
                let moduleName = moveCallArguments.module
                let functionName = moveCallArguments.name
                
                let normalized = try await provider.getNormalizedMoveFunction(
                    normalizeSuiAddress(value: packageId),
                    moduleName,
                    functionName
                )

                let hasTxContext = normalized.hasTxContext()
                let params = hasTxContext ? normalized.parameters.dropLast() : normalized.parameters
                guard params.count == moveCallTx.arguments.count else { throw SuiError.notImplemented }

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
                            blockData.inputs[Int(blockInputArgument.index)].value = .input(
                                Inputs.pure(data: try inputValue.dataValue())
                            )
                            return
                        }
                        guard param.extractStructTag() != nil || param.type == "TypeParameter" else { throw SuiError.notImplemented }
                        guard inputValue.kind == .string else { throw SuiError.notImplemented }

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
                            throw SuiError.notImplemented
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
                let result = try await provider.getMultiObjects($0, GetObject(showOwner: true))
                objects.append(contentsOf: result)
            }
            
            var objectsById: [String : SuiObjectResponse] = [:]
            zip(dedupedIds, objects).forEach { (id, object) in
                objectsById[id] = object
            }
            let invalidObjects = objectsById.filter { _, obj in obj.error != nil }.map { key, _ in key }
            guard invalidObjects.isEmpty else { throw SuiError.notImplemented }
            var resolvedIds: [String: Range<Array<ObjectsToResolve>.Index>.Element] = [:]
            for i in objectsToResolve.indices {
                var idx = i
                var mutable: Bool = false
                var objectToResolve = objectsToResolve[idx]
                switch objectToResolve.input.value {
                case .callArg(let callArg):
                    mutable = callArg.isMutableSharedObjectInput()
                case .input(let input):
                    mutable = input.isMutableSharedObjectInput()
                default:
                    break
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
                    let objRef = object.getObjectReference()
                    objectsToResolve[idx].input.value = .input(
                        try Inputs.objectRef(suiObjectRef: objRef)
                    )
                    resolvedIds[objectToResolve.id] = idx
                    continue
                }
                objectsToResolve[idx].input.value = .input(
                    try Inputs.sharedObjectRef(
                        sharedObjectRef: SharedObjectRef(
                            objectId: objectToResolve.id,
                            initialSharedVersion: UInt64(initialSharedVersion),
                            mutable: mutable
                        )
                    )
                )
                resolvedIds[objectToResolve.id] = idx
            }
            if resolvedIds.count != objectsToResolve.count {
                self.blockData.serializedTransactionDataBuilder.inputs = []
                for object in objectsToResolve {
                    self.blockData.serializedTransactionDataBuilder.inputs.append(object.input)
                }
            } else {
                for objectToResolve in objectsToResolve {
                    self.blockData.serializedTransactionDataBuilder.inputs[Int(objectToResolve.input.index)] = objectToResolve.input
                }
            }
        }
    }
    
    private mutating func prepare(_ optionsPassed: BuildOptions) async throws {
        guard !(self.isPreparred) else { return }
        var options: BuildOptions = optionsPassed
        
        guard let provider = options.provider else {
            throw SuiError.notImplemented
        }
        
        if options.protocolConfig == nil && options.limits == nil {
            options.protocolConfig = try await provider.getProtocolConfig()
        }
        
        try await self.prepareGasPrice(provider: provider, onlyTransactionKind: options.onlyTransactionKind ?? false)
        try await self.prepareTransactions(provider: provider)
        
        if (options.onlyTransactionKind == nil) || (options.onlyTransactionKind != nil && !(options.onlyTransactionKind!)) {
            let onlyTransactionKind = options.onlyTransactionKind
            
            try await self.prepareGasPayment(provider: provider, onlyTransactionKind: onlyTransactionKind)
            if self.blockData.serializedTransactionDataBuilder.gasConfig.budget == nil {
                let blockData = self.blockData
                var gasConfig = blockData.serializedTransactionDataBuilder.gasConfig
                gasConfig.budget = String(try self.getConfig(key: LimitsKey.maxTxGas, buildOptions: options))
                gasConfig.payment = []
                let txBlockDataBuilder = try TransactionBlockDataBuilder(
                    serializedTransactionDataBuilder: SerializedTransactionDataBuilder(gasConfig: gasConfig)
                )
                let dryRunResult = try await provider.dryRunTransactionBlock([UInt8](blockData.build(overrides: txBlockDataBuilder)))
                guard dryRunResult["effects"]["status"]["status"].stringValue != "failure" else {
                    throw SuiError.notImplemented
                }
                let safeOverhead = TransactionConstants.GAS_SAFE_OVERHEAD * (
                    Int(blockData.serializedTransactionDataBuilder.gasConfig.price ?? "1") ?? 1
                )
                let baseComputationCostWithOverhead = dryRunResult["effects"]["gasUsed"]["computationCost"].intValue + safeOverhead
                let gasBudget =
                baseComputationCostWithOverhead +
                dryRunResult["effects"]["gasUsed"]["storageCost"].intValue -
                dryRunResult["effects"]["gasUsed"]["storageRebate"].intValue
                self.setGasBudget(
                    price:
                        gasBudget > baseComputationCostWithOverhead ?
                    BigInt(gasBudget) :
                        BigInt(baseComputationCostWithOverhead)
                )
            }
        }
        self.isPreparred = true
    }
    
    private func isMissingSender(_ onlyTransactionKind: Bool? = nil) -> Bool {
        return
            onlyTransactionKind != nil &&
            !(onlyTransactionKind!) &&
            self.blockData.serializedTransactionDataBuilder.sender == nil
    }
    
    private func isTxcontext(_ param: SuiMoveNormalizedType) -> Bool {
        let structTag = self.extractStructTag(param)
        
        return
            structTag?.address == "0x2" &&
            structTag?.module == "tx_context" &&
            structTag?.name == "TxContext"
    }
    
    private func extractStructTag(_ normalizedType: SuiMoveNormalizedType) -> SuiMoveNormalizedStructType? {
        let ref = self.extractReference(normalizedType)
        let mutRef = self.extractMutableReference(normalizedType)
        
        switch ref {
        case .structure(let structure):
            return structure
        default:
            break
        }
        
        switch mutRef {
        case .structure(let structure):
            return structure
        default:
            break
        }
        
        return nil
    }
    
    private func extractReference(_ normalizedType: SuiMoveNormalizedType) -> SuiMoveNormalizedType? {
        switch normalizedType {
        case .reference(let suiMoveNormalizedType):
            return .reference(suiMoveNormalizedType)
        default:
            return nil
        }
    }
    
    private func extractMutableReference(_ normalizedType: SuiMoveNormalizedType) -> SuiMoveNormalizedType? {
        switch normalizedType {
        case .mutableReference(let suiMoveNormalizedType):
            return .mutableReference(suiMoveNormalizedType)
        default:
            return nil
        }
    }
    
    private func getPureSerializationType(_ normalizedType: SuiMoveNormalizedType, _ argVal: SuiJsonValue) throws -> String? {
        enum AllowedTypes: String {
            case Address
            case Bool
            case U8
            case U16
            case U32
            case U64
            case U128
            case U256
            
            public static func isAllowed(_ input: SuiMoveNormalizedType) -> Bool {
                return AllowedTypes(rawValue: input.type) != nil
            }
        }
        
        if AllowedTypes.isAllowed(normalizedType) {
            switch normalizedType {
            case .bool:
                try self.expectType("boolean", argVal)
            case .u8, .u16, .u32, .u64, .u128, .u256:
                try self.expectType("number", argVal)
            case .address, .signer:
                try self.expectType("string", argVal)
                switch argVal {
                case .string(let str):
                    guard self.isValidSuiAddress(str) else { throw SuiError.notImplemented }
                default:
                    throw SuiError.notImplemented
                }
            default: break
            }
            return normalizedType.type.lowercased()
        }
        
        switch normalizedType {
        case .vector(let normalizedTypeVector):
            if argVal.kind == .string, normalizedTypeVector.type == "U8" {
                return "string"
            }
            let innerType = try self.getPureSerializationType(normalizedTypeVector, argVal)
            guard innerType != nil else { return nil }
            return "vector<\(innerType!)>"
        case .structure(let normalizedStruct):
            if self.isSameStruct(normalizedStruct, ResolvedAsciiStr()) {
                return "string"
            }
            if self.isSameStruct(normalizedStruct, ResolvedUtf8Str()) {
                return "utf8string"
            }
            if self.isSameStruct(normalizedStruct, ResolvedSuiId()) {
                return "address"
            }
            if self.isSameStruct(normalizedStruct, ResolvedStdOption()) {
                let optionToVec: SuiMoveNormalizedType = .vector(normalizedStruct.typeArguments[0])
                return try self.getPureSerializationType(optionToVec, argVal)
            }
        default: break
        }
        
        return nil
    }
    
    private func expectType(_ typeName: String, _ argVal: SuiJsonValue) throws {
        if SuiJsonValueType(rawValue: typeName) == nil {
            throw SuiError.notImplemented
        }
        if (SuiJsonValueType(rawValue: typeName))! != argVal.kind {
            throw SuiError.notImplemented
        }
    }
    
    private func isValidSuiAddress(_ value: String) -> Bool {
        return isHex(value) && self.getHexByteLength(value) == 32
    }
    
    private func isHex(_ value: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(0x|0X)?[a-fA-F0-9]+$")
        let range = NSRange(location: 0, length: value.utf16.count)
        let match = regex.firstMatch(in: value, options: [], range: range)
        
        return match != nil && value.count % 2 == 0
    }
    
    private func getHexByteLength(_ value: String) -> Int {
        if value.hasPrefix("0x") || value.hasPrefix("0X") {
            return (value.count - 2) / 2
        } else {
            return value.count / 2
        }
    }
    
    private func isSameStruct(_ lhs: SuiMoveNormalizedStructType, _ rhs: any ResolvedProtocol) -> Bool {
        return
            lhs.address == rhs.address &&
            lhs.module == rhs.module &&
            lhs.name == rhs.name
    }
    
    private func getSharedObjectInitialVersion(_ resp: SuiObjectResponse) -> Int? {
        if let owner = resp.owner, let initialSharedVersion = owner.shared?.shared.initialSharedVersion {
            return initialSharedVersion
        }
        return nil
    }
    
    private func getSharedObjectInput(_ arg: SuiCallArg) -> SharedObjectSuiCallArg? {
        switch arg {
        case .sharedObject(let sharedObjectSuiCallArg):
            return sharedObjectSuiCallArg
        default: return nil
        }
    }
    
    private func isMutableSharedObjectInput(_ arg: SuiCallArg) -> Bool {
        return self.getSharedObjectInput(arg)?.mutable ?? false
    }
    
    private func getObjectReference(_ resp: SuiObjectResponse) -> SuiObjectRef? {
        return SuiObjectRef(
            objectId: resp.objectId,
            version: resp.version,
            digest: resp.digest
        )
    }
}

public struct ResolvedStdOption: ResolvedProtocol {
    public var address: String = ResolvedConstants.moveStdlibAddress
    public var module: String = ResolvedConstants.stdOptionModuleName
    public var name: String = ResolvedConstants.stdOptionStructName
}

public struct ResolvedUtf8Str: ResolvedProtocol {
    public var address: String = ResolvedConstants.moveStdlibAddress
    public var module: String = ResolvedConstants.stdUtf8ModuleName
    public var name: String = ResolvedConstants.stdUtf8StructName
}

public struct ResolvedAsciiStr: ResolvedProtocol {
    public var address: String = ResolvedConstants.moveStdlibAddress
    public var module: String = ResolvedConstants.stdAsciiModuleName
    public var name: String = ResolvedConstants.stdAsciiStructName
}

public struct ResolvedSuiId: ResolvedProtocol {
    public var address: String = ResolvedConstants.suiFrameworkAddress
    public var module: String = ResolvedConstants.objectModuleName
    public var name: String = ResolvedConstants.idStructName
}

public struct ResolvedConstants {
    public static let stdOptionStructName = "Option"
    public static let stdOptionModuleName = "option"
    
    public static let stdUtf8StructName = "String"
    public static let stdUtf8ModuleName = "string"
    
    public static let stdAsciiStructName = "String"
    public static let stdAsciiModuleName = "ascii"
    
    public static let suiSystemAddress = "0x3"
    public static let suiFrameworkAddress = "0x2"
    public static let moveStdlibAddress = "0x1"
    
    public static let objectModuleName = "object"
    public static let uidStructName = "UID"
    public static let idStructName = "ID"
    
    public static let suiTypeArg = "\(ResolvedConstants.suiFrameworkAddress)::sui::SUI"
    public static let validatorsEventQuery = "\(ResolvedConstants.suiSystemAddress)::validator_set::ValidatorEpochInfoEventV2"
}

public enum ProtocolConfigValue {
    case u32(String)
    case u64(String)
    case f64(String)
}

public struct ProtocolConfig {
    public let attributes: [String: ProtocolConfigValue?]
    public let featureFlags: [String: Bool]
    public let maxSupportedProtocolVersion: String
    public let minSupportedProtocolVersion: String
    public let protocolVersion: String
}

public let LIMITS: [String: String] = [
    // The maximum gas that is allowed.
    "maxTxGas": "max_tx_gas",
    // The maximum number of gas objects that can be selected for one transaction.
    "maxGasObjects": "max_gas_payment_objects",
    // The maximum size (in bytes) that the transaction can be.
    "maxTxSizeBytes": "max_tx_size_bytes",
    // The maximum size (in bytes) that pure arguments can be.
    "maxPureArgumentSize": "max_pure_argument_size"
]

public typealias Limits = [String: Int?]

public enum LimitsKey: String {
    case maxTxGas = "max_tx_gas"
    case maxGasObjects = "max_gas_payment_objects"
    case maxTxSizeBytes = "max_tx_size_bytes"
    case maxPureArgumentSize = "max_pure_argument_size"
}

public struct ObjectsToResolve {
    let id: String
    var input: TransactionBlockInput
    let normalizedType: SuiMoveNormalizedType?
}
