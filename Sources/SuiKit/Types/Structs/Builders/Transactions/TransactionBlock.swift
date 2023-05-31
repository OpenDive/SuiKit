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
    
    public init(index: Int) {
        self.transactionArgument = TransactionArgument.result(
            Result(kind: "Result", index: index)
        )
        self.nestedResults = []
    }
    
    public func nestedResultFor(_ resultIndex: Int) -> TransactionArgument? {
        if nestedResults.indices.contains(resultIndex) {
            return nestedResults[resultIndex]
        } else {
            switch transactionArgument {
            case .result(let result):
                let nestedResult = TransactionArgument.nestedResult(
                    NestedResult(
                        kind: "NestedResult",
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
    
    public subscript(index: Int) -> TransactionArgument? {
        return nestedResultFor(index)
    }
}

public struct TransactionConstants {
    public static let MAX_GAS_OBJECTS = 256
    public static let MAX_GAS = 50_000_000_000
    public static let GAS_SAFE_OVERHEAD = 1_000
    public static let MAX_OBJECTS_PER_FETCH = 50
}

public struct BuildOptions {
    public let provider: SuiProvider?
    public let onlyTransactionKind: Bool?
}

public struct TransactionBlock {
    public var transactionBrand: Bool = true
    public var blockData: TransactionBlockDataBuilder?
    
    public static func isInstance(_ obj: Any) -> Bool {
        guard let obj = obj as? TransactionBlock else { return false }
        return obj.transactionBrand
    }
    
    public static func fromKind(serialized: Data) throws -> TransactionBlock {
        var tx = TransactionBlock()
        tx.blockData = try TransactionBlockDataBuilder.fromKindBytes(
            bytes: serialized
        )
        return tx
    }
    
    public static func fromKind(serialized: String) throws -> TransactionBlock {
        var tx = TransactionBlock()
        tx.blockData = try TransactionBlockDataBuilder.fromKindBytes(
            bytes: Data(B64.fromB64(sBase64: serialized))
        )
        return tx
    }
    
    public static func from(serialized: Data) throws -> TransactionBlock {
        var tx = TransactionBlock()
        tx.blockData = try TransactionBlockDataBuilder.fromBytes(bytes: serialized)
        return tx
    }
    
    public static func from(serialized: String) throws -> TransactionBlock {
        var tx = TransactionBlock()
        
        if serialized.starts(with: "{") {
            guard let data = serialized.data(using: .utf8) else { throw SuiError.notImplemented }
            let resultData = try JSONDecoder().decode(
                SerializedTransactionDataBuilder.self, from: data
            )
            tx.blockData = TransactionBlockDataBuilder.restore(data: resultData)
        } else {
            tx.blockData = try TransactionBlockDataBuilder.fromBytes(
                bytes: Data(B64.fromB64(sBase64: serialized))
            )
        }
        
        return tx
    }
    
    mutating public func setSender(sender: SuiAddress) {
        self.blockData?.serializedTransactionDataBuilder.sender = sender
    }
    
    mutating public func setSenderIfNotSet(sender: SuiAddress) {
        if ((self.blockData?.serializedTransactionDataBuilder.sender) == nil) {
            self.blockData?.serializedTransactionDataBuilder.sender = sender
        }
    }
    
    mutating public func setExpiration(expiration: TransactionExpiration) {
        self.blockData?.serializedTransactionDataBuilder.expiration = expiration
    }
    
    mutating public func setGasPrice(price: BigInt) {
        self.blockData?.serializedTransactionDataBuilder.gasConfig.price = "\(price)"
    }
    
    mutating public func setGasPrice(price: Int) {
        self.blockData?.serializedTransactionDataBuilder.gasConfig.price = "\(price)"
    }
    
    mutating public func setGasBudget(price: BigInt) {
        self.blockData?.serializedTransactionDataBuilder.gasConfig.budget = "\(price)"
    }
    
    mutating public func setGasBudget(price: Int) {
        self.blockData?.serializedTransactionDataBuilder.gasConfig.budget = "\(price)"
    }
    
    mutating public func setGasOwner(owner: String) {
        self.blockData?.serializedTransactionDataBuilder.gasConfig.owner = owner
    }
    
    mutating public func setGasPayment(payments: [SuiObjectRef]) throws {
        guard payments.count < TransactionConstants.MAX_GAS_OBJECTS else {
            throw SuiError.notImplemented
        }
        self.blockData?.serializedTransactionDataBuilder.gasConfig.payment = payments
    }
    
    mutating private func input(type: ValueType, value: SuiJsonValue?) throws -> TransactionBlockInput {
        guard let index = self.blockData?.serializedTransactionDataBuilder.inputs.count else {
            throw SuiError.notImplemented
        }
        let input = TransactionBlockInput(
            kind: "Input",
            index: index,
            value: value,
            type: type
        )
        self.blockData?.serializedTransactionDataBuilder.inputs.append(input)
        return input
    }
    
    public mutating func object(value: objectId) throws -> [TransactionBlockInput] {
        let id = getIdFromCallArg(arg: value)
        guard let blockData = self.blockData else { throw SuiError.notImplemented }
        let inserted = blockData.serializedTransactionDataBuilder.inputs.filter { input in
            if input.type == .object {
                guard let valueEnum = input.value else { return false }
                switch valueEnum {
                case .callArg(let callArg):
                    switch callArg {
                    case .object(let objectArg):
                        return id == getIdFromCallArg(arg: ObjectCallArg(object: objectArg))
                    default:
                        return false
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
        
        return [
            try self.input(
                type: .object,
                value: SuiJsonValue.string(value)
            )
        ]
    }
    
    public mutating func object(value: ObjectCallArg) throws -> [TransactionBlockInput] {
        let id = getIdFromCallArg(arg: value)
        guard let blockData = self.blockData else { throw SuiError.notImplemented }
        let inserted = blockData.serializedTransactionDataBuilder.inputs.filter { input in
            if input.type == .object {
                guard let valueEnum = input.value else { return false }
                switch valueEnum {
                case .callArg(let callArg):
                    switch callArg {
                    case .object(let objectArg):
                        return id == getIdFromCallArg(arg: ObjectCallArg(object: objectArg))
                    default:
                        return false
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
        
        return [
            try self.input(
                type: .object,
                value: SuiJsonValue.callArg(
                    CallArg.object(value.object)
                )
            )
        ]
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
    
    public mutating func add(transaction: SuiTransaction) throws -> TransactionArgument {
        self.blockData?.serializedTransactionDataBuilder.transactions.append(transaction)
        guard let index = self.blockData?.serializedTransactionDataBuilder.transactions.count else {
            throw SuiError.notImplemented
        }
        guard let result = TransactionResult(index: index - 1)[index - 1] else {
            throw SuiError.notImplemented
        }
        return result
    }
    
    public mutating func splitCoin(coin: TransactionBlockInput, amounts: [TransactionBlockInput]) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.splitCoins(
                Transactions.splitCoins(
                    coins: ObjectTransactionArgument(
                        argument: TransactionArgument.transactionBlockInput(coin)
                    ),
                    amounts: amounts.map { TransactionArgument.transactionBlockInput($0) }
                )
            )
        )
    }

    public mutating func mergeCoin(destination: TransactionBlockInput, sources: [TransactionBlockInput]) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.mergeCoins(
                Transactions.mergeCoins(
                    destination: ObjectTransactionArgument(
                        argument: TransactionArgument.transactionBlockInput(destination)
                    ),
                    sources: sources.map {
                        ObjectTransactionArgument(
                            argument: TransactionArgument.transactionBlockInput($0)
                        )
                    }
                )
            )
        )
    }

    public mutating func publish(
        modules: [Data],
        dependencies: [objectId]
    ) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.publish(
                Transactions.publish(
                    modules: modules.map { [UInt8]($0) },
                    dependencies: dependencies
                )
            )
        )
    }
    
    public mutating func upgrade(
        modules: [Data],
        dependencies: [objectId],
        packageId: objectId,
        ticket: TransactionBlockInput
    ) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.upgrade(
                Transactions.upgrade(
                    modules: modules.map { [UInt8]($0) },
                    dependencies: dependencies,
                    packageId: packageId,
                    ticket: ObjectTransactionArgument(
                        argument: TransactionArgument.transactionBlockInput(ticket)
                    )
                )
            )
        )
    }
    
    public mutating func moveCall(target: String, arguments: [TransactionArgument]?, typeArguments: [String]?) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.moveCall(
                Transactions.moveCall(
                    input: MoveCallTransactionInput(
                        target: target,
                        arguments: arguments,
                        typeArguments: typeArguments
                    )
                )
            )
        )
    }
    
    public mutating func transferObject(objects: [TransactionBlockInput], address: TransactionBlockInput) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.transferObjects(
                Transactions.transferObjects(
                    objects: objects.map {
                        ObjectTransactionArgument(
                            argument: TransactionArgument.transactionBlockInput($0)
                        )
                    },
                    address: PureTransactionArgument(
                        argument: TransactionArgument.transactionBlockInput(address),
                        type: "address"
                    )
                )
            )
        )
    }
    
    public mutating func makeMoveVec(type: String? = nil, objects: [TransactionBlockInput]) throws -> TransactionArgument {
        try self.add(
            transaction: SuiTransaction.makeMoveVec(
                Transactions.makeMoveVec(
                    type: type,
                    objects: objects.map {
                        ObjectTransactionArgument(
                            argument: TransactionArgument.transactionBlockInput($0)
                        )
                    }
                )
            )
        )
    }

    public func serialize() throws -> Data {
        guard let blockData = self.blockData else { throw SuiError.notImplemented }
        return try JSONEncoder().encode(blockData.snapshot())
    }
    
    // TODO: Implement build function
    public func build() {
        
    }
    
    // TODO: Implement getDigest function
    public func getDigest() {
        
    }
    
    private mutating func prepareGasPayment(provider: SuiProvider, onlyTransactionKind: Bool? = nil) async throws {
        if self.isMissingSender(onlyTransactionKind) {
            throw SuiError.notImplemented
        }
        
        guard let gasOwner =
            self.blockData?.serializedTransactionDataBuilder.gasConfig.owner ??
            self.blockData?.serializedTransactionDataBuilder.sender
        else {
            throw SuiError.notImplemented
        }
        
        let coins = try await provider.getCoins(
            AccountAddress.fromHex(gasOwner),
            "0x2::sui::SUI"
        )
        
        let paymentCoins = coins.data.filter { coin in
            let matchingInput = self.blockData?.serializedTransactionDataBuilder.inputs.filter { input in
                if let value = input.value {
                    switch value {
                    case .callArg(let callArg):
                        switch callArg {
                        case .object(let objectArg):
                            switch objectArg {
                            case .immOrOwned(let immOrOwned):
                                return coin.coinObjectId == immOrOwned.immOrOwned.objectId
                            default:
                                return false
                            }
                        default:
                            return false
                        }
                    default:
                        return false
                    }
                }
                return false
            }
            
            return matchingInput != nil && !matchingInput!.isEmpty
        }[0..<TransactionConstants.MAX_GAS_OBJECTS].map { coin in
            SuiObjectRef(
                version: UInt8(Int(coin.version) ?? 0),
                objectId: coin.coinObjectId,
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
    
    // TODO: Implement prepareTransactions function
    private mutating func prepareTransactions(provider: SuiProvider) async throws {
        guard let blockData = self.blockData?.serializedTransactionDataBuilder else {
            throw SuiError.notImplemented
        }
        
        var moveModulesToResolve: [MoveCallTransaction] = []
        
        struct ObjectsToResolve {
            let id: String
            let input: TransactionBlockInput
            let normalizedType: SuiMoveNormalizedType
        }
        
        var objectsToResolve: [ObjectsToResolve] = []
        
        blockData.transactions.forEach { tx in
            if tx.kind == "MoveCall" {
                switch tx {
                case .moveCall(let moveCall):
                    let needsResolution = moveCall.arguments.allSatisfy { argument in
                        switch argument {
                        case .transactionBlockInput(let transactionBlockInput):
                            switch blockData.inputs[transactionBlockInput.index].value {
                            case .callArg:
                                return false
                            default:
                                return true
                            }
                        default:
                            return false
                        }
                    }
                    
                    if needsResolution {
                        moveModulesToResolve.append(moveCall)
                    }
                    
                    return
                default:
                    break
                }
            }
            
//            let transactionType = self.get
        }
    }
    
    // TODO: Implement prepare function
    private mutating func prepare(provider: SuiProvider, onlyTransactionKind: Bool? = nil) async throws {
        if self.isMissingSender(onlyTransactionKind) {
            throw SuiError.notImplemented
        }
        
        try await self.prepareGasPrice(provider: provider, onlyTransactionKind: onlyTransactionKind)
        try await self.prepareTransactions(provider: provider)
        
        if onlyTransactionKind != nil && !(onlyTransactionKind!) {
            try await self.prepareGasPayment(provider: provider, onlyTransactionKind: onlyTransactionKind)
        }
    }
    
    private func isMissingSender(_ onlyTransactionKind: Bool? = nil) -> Bool {
        return
            onlyTransactionKind != nil &&
            !(onlyTransactionKind!) &&
            self.blockData?.serializedTransactionDataBuilder.sender == nil
    }
}
