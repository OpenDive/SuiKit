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
    
    // TODO: Implement Object Ref function
    
    // TODO: Implement build function
    
    // TODO: Implement getDigest function
    
    // TODO: Implement prepareGasPrice function
    
    // TODO: Implement various client functions
    
    // TODO: Implement prepareTransactions function
    
    // TODO: Implement prepare function
}
