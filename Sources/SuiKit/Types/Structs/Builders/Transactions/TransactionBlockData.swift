//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/13/23.
//

import Foundation
import BigInt
import CryptoKit
import Base58Swift

public struct TransactionBlockDataBuilder {
    public var serializedTransactionDataBuilder: SerializedTransactionDataBuilder
    
    public static func fromKindBytes(bytes: Data) throws -> TransactionBlockDataBuilder {
        let kind = try SuiTransactionBlockKind.deserialize(from: Deserializer(data: bytes))
        
        switch kind {
        case .programmableTransaction(let programmableTransaction):
            return TransactionBlockDataBuilder(
                serializedTransactionDataBuilder: SerializedTransactionDataBuilder(
                    sender: nil,
                    expiration: TransactionExpiration.none(true),
                    gasConfig: SuiGasData(),
                    inputs: programmableTransaction.inputs.enumerated().map { (idx, value) in
                        switch value {
                        case .pure(let pureSuiCallArg):
                            return TransactionBlockInput(
                                index: idx,
                                value: pureSuiCallArg.value,
                                type: .pure
                            )
                        default:
                            return TransactionBlockInput(
                                index: idx,
                                value: nil,
                                type: .object
                            )
                        }
                    },
                    transactions: programmableTransaction.transactions
                )
            )
        default:
            throw SuiError.notImplemented
        }
    }
    
    public static func fromBytes(bytes: Data) throws -> TransactionBlockDataBuilder {
        let rawData = try TransactionData.deserialize(from: Deserializer(data: bytes))
        
        switch rawData.kind {
        case .programmableTransaction(let programmableTransaction):
            return TransactionBlockDataBuilder(
                serializedTransactionDataBuilder: SerializedTransactionDataBuilder(
                    sender: rawData.sender,
                    expiration: rawData.expiration,
                    gasConfig: rawData.gasData,
                    inputs: programmableTransaction.inputs.enumerated().map { (idx, value) in
                        switch value {
                        case .pure(let pureSuiCallArg):
                            return TransactionBlockInput(
                                index: idx,
                                value: pureSuiCallArg.value,
                                type: .pure
                            )
                        default:
                            return TransactionBlockInput(
                                index: idx,
                                value: nil,
                                type: .object
                            )
                        }
                    },
                    transactions: programmableTransaction.transactions
                )
            )
        default:
            throw SuiError.notImplemented
        }
    }
    
    public static func getDigestFromBytes(bytes: Data) -> String {
        let hash = hashTypedData(typeTag: "TransactionData", data: bytes)
        return Base58.base58Encode(hash)
    }
    
    public static func restore(data: SerializedTransactionDataBuilder) -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(serializedTransactionDataBuilder: data)
    }
    
    public func build(
        overrides: TransactionBlockDataBuilder? = nil,
        onlyTransactionKind: Bool? = nil,
        isCorrect: Bool = false
    ) throws -> Data {
        let inputs = self.serializedTransactionDataBuilder.inputs.compactMap { value in
            switch value.value {
            case .callArg(let callArg):
                return callArg
            default:
                return nil
            }
        }
        
        let transactions = self.serializedTransactionDataBuilder.transactions
        
        let kind = ProgrammableTransaction(transactions: transactions, inputs: inputs)
        
        if let onlyTransactionKind, onlyTransactionKind {
            let ser = Serializer()
            try SuiTransactionBlockKind.programmableTransaction(kind).serialize(ser)
            return ser.output()
        }
        
        let expiration = overrides?.serializedTransactionDataBuilder.expiration ?? self.serializedTransactionDataBuilder.expiration
        let senderUnwrapped = overrides?.serializedTransactionDataBuilder.sender ?? self.serializedTransactionDataBuilder.sender
        let gasConfig = overrides?.serializedTransactionDataBuilder.gasConfig ?? self.serializedTransactionDataBuilder.gasConfig
        
        guard
            let sender = senderUnwrapped,
            let budget = gasConfig.budget,
            let payment = gasConfig.payment,
            let price = gasConfig.price
        else {
            throw SuiError.notImplemented
        }
        
        let transactionData = TransactionData(
            kind: SuiTransactionBlockKind.programmableTransaction(kind),
            sender: prepareSuiAddress(address: sender),
            gasData: SuiGasData(
                payment: payment,
                owner: prepareSuiAddress(
                    address: self.serializedTransactionDataBuilder.gasConfig.owner ?? sender
                ),
                price: price,
                budget: budget
            ),
            expiration: expiration ?? TransactionExpiration.none(true)
        )
        
//        if isCorrect {
//            print(transactionData)
//            switch transactionData {
//            case .V1(let txV1):
//                switch txV1.kind {
//                case .programmableTransaction(let programmableTx):
//                    for tx in programmableTx.transactions {
//                        switch tx.suiTransaction {
//                        case .moveCall(let moveCallTransaction):
//                            print("DEBUG: MOVE CALL - \(moveCallTransaction)")
//                        case .transferObjects(let transferObjectsTransaction):
//                            print("DEBUG: TRANSFER OBJECT - \(transferObjectsTransaction)")
//                        case .splitCoins(let splitCoinsTransaction):
//                            print("DEBUG: SPLIT COINS - \(splitCoinsTransaction)")
//                        case .mergeCoins(let mergeCoinsTransaction):
//                            print("DEBUG: MERGE COINS - \(mergeCoinsTransaction)")
//                        case .publish(let publishTransaction):
//                            print("DEBUG: PUBLISH - \(publishTransaction)")
//                        case .upgrade(let upgradeTransaction):
//                            print("DEBUG: UPGRADE - \(upgradeTransaction)")
//                        case .makeMoveVec(let makeMoveVecTransaction):
//                            print("DEBUG: MOVE VEC - \(makeMoveVecTransaction)")
//                        }
//                    }
//                default:
//                    break
//                }
//                break
//            }
//        }
        
        let ser = Serializer()
        try transactionData.serialize(ser)
        return ser.output()
    }
    
    public func getDigest() throws -> String {
        let bytes = try self.build()
        return TransactionBlockDataBuilder.getDigestFromBytes(bytes: bytes)
    }
    
    public func snapshot() -> SerializedTransactionDataBuilder {
        return self.serializedTransactionDataBuilder
    }
}

public let TRANSACTION_DATA_MAX_SIZE = 128 * 1024

public func prepareSuiAddress(address: String) -> String {
    return normalizeSuiAddress(value: address).replacingOccurrences(of: "0x", with: "")
}

public func hashTypedData(typeTag: String, data: Data) -> [UInt8] {
    let typeTagBytes = Array(typeTag.utf8) + Array("::".utf8)
    
    var dataWithTag = [UInt8]()
    dataWithTag.append(contentsOf: typeTagBytes)
    dataWithTag.append(contentsOf: data)
    
    let hashedData = SHA256.hash(data: Data(dataWithTag))
    
    return Array(hashedData)
}

public class SerializedTransactionDataBuilder {
    public var version: UInt8 = 1
    public var sender: SuiAddress?
    public var expiration: TransactionExpiration?
    public var gasConfig: SuiGasData
    public var inputs: [TransactionBlockInput]
    public var transactions: [SuiTransaction]
    
    enum CodingKeys: String, CodingKey {
        case version
        case sender
        case expiration
        case gasConfig
        case inputs
        case transactions
    }
    
    public init(
        sender: SuiAddress? = nil,
        expiration: TransactionExpiration? = TransactionExpiration.none(true),
        gasConfig: SuiGasData = SuiGasData(),
        inputs: [TransactionBlockInput] = [],
        transactions: [SuiTransaction] = []
    ) {
        self.sender = sender
        self.expiration = expiration
        self.gasConfig = gasConfig
        self.inputs = inputs
        self.transactions = transactions
    }
}

public enum TransactionExpiration: KeyProtocol {
    case epoch(UInt64)
    case none(Bool)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .epoch(let int):
            try Serializer.u64(serializer, int)
        case .none(let bool):
            try Serializer.bool(serializer, bool)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionExpiration {
        if let intReturn = try? Deserializer.u64(deserializer) {
            return .epoch(intReturn)
        } else if let boolReturn = try? deserializer.bool() {
            return .none(boolReturn)
        } else {
            throw SuiError.notImplemented
        }
    }
}

public struct StringEncodedBigInt {
    public let value: BigInt
    
    public init?(from value: Any) {
        switch value {
        case let string as String:
            guard let bigInt = BigInt(string) else { return nil }
            self.value = bigInt
        case let int as Int:
            self.value = BigInt(int)
        case let bigInt as BigInt:
            self.value = bigInt
        default:
            return nil
        }
    }
}
