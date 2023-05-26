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
                    expiration: .none,
                    gasConfig: SuiGasData(),
                    inputs: programmableTransaction.inputs.enumerated().map { (idx, value) in
                        switch value {
                        case .pure(let pureSuiCallArg):
                            return TransactionBlockInput(
                                kind: "Input",
                                index: idx,
                                value: pureSuiCallArg.value,
                                valueType: .pure
                            )
                        default:
                            return TransactionBlockInput(
                                kind: "Input",
                                index: idx,
                                value: nil,
                                valueType: .object
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
        
        switch rawData {
        case .V1(let transactionDataV1):
            switch transactionDataV1.kind {
            case .programmableTransaction(let programmableTransaction):
                return TransactionBlockDataBuilder(
                    serializedTransactionDataBuilder: SerializedTransactionDataBuilder(
                        sender: transactionDataV1.sender,
                        expiration: transactionDataV1.expiration,
                        gasConfig: transactionDataV1.gasData,
                        inputs: programmableTransaction.inputs.enumerated().map { (idx, value) in
                            switch value {
                            case .pure(let pureSuiCallArg):
                                return TransactionBlockInput(
                                    kind: "Input",
                                    index: idx,
                                    value: pureSuiCallArg.value,
                                    valueType: .pure
                                )
                            default:
                                return TransactionBlockInput(
                                    kind: "Input",
                                    index: idx,
                                    value: nil,
                                    valueType: .object
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
    }
    
    public static func getDigestFromBytes(bytes: Data) -> String {
        let hash = hashTypedData(typeTag: "TransactionData", data: bytes)
        return Base58.base58Encode(hash)
    }
    
    public func build(
        overrides: TransactionBlockDataBuilder? = nil,
        onlyTransactionKind: Bool? = nil
    ) throws -> Data {
        let inputsCallArgs = self.serializedTransactionDataBuilder.inputs.compactMap { value in
            switch value.value {
            case .callArg(let callArg):
                return callArg
            default:
                return nil
            }
        }
        
        let inputs: [SuiCallArg] = inputsCallArgs.map { value in
            switch value {
            case .pure(let pureObject):
                let jsonValues: [SuiJsonValue] = pureObject.pure.map { SuiJsonValue.number(UInt64($0)) }
                return SuiCallArg.pure(PureSuiCallArg(
                    type: "pure",
                    valueType: nil,
                    value: SuiJsonValue.array(jsonValues)
                ))
            case .object(let objectArg):
                switch objectArg {
                case .immOrOwned(let immOrOwned):
                    return SuiCallArg.ownedObject(OwnedObjectSuiCallArg(
                        type: "object",
                        objectType: "immOrOwnedObject",
                        objectId: immOrOwned.immOrOwned.objectId,
                        version: "\(immOrOwned.immOrOwned.version)",
                        digest: immOrOwned.immOrOwned.digest
                    ))
                case .shared(let sharedArg):
                    return SuiCallArg.sharedObject(SharedObjectSuiCallArg(
                        type: "object",
                        objectType: "sharedObject",
                        objectId: sharedArg.shared.objectId,
                        initialSharedVersion: "\(sharedArg.shared.initialSharedVersion)",
                        mutable: sharedArg.shared.mutable
                    ))
                }
            }
        }
        
        let transactions = self.serializedTransactionDataBuilder.transactions.compactMap {
            if let tx = $0 as? SuiTransaction {
                return tx
            }
            return nil
        }
        
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
        
        let transactionData = TransactionData.V1(TransactionDataV1(
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
            expiration: expiration
        ))
        
        let ser = Serializer()
        try transactionData.serialize(ser)
        return ser.output()
    }

    public func getDigest() throws -> String {
        let bytes = try self.build()
        return TransactionBlockDataBuilder.getDigestFromBytes(bytes: bytes)
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

public struct SerializedTransactionDataBuilder {
    public let version: UInt8 = 1
    public let sender: SuiAddress?
    public let expiration: TransactionExpiration
    public let gasConfig: SuiGasData
    public let inputs: [TransactionBlockInput]
    public let transactions: [any TransactionTypesProtocol]
}

public enum TransactionExpiration: KeyProtocol {
    case epoch(Int)
    case none
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .epoch(let int):
            try Serializer.u8(serializer, 0)
            try Serializer.u64(serializer, UInt64(int))
        case .none:
            try Serializer.u8(serializer, 1)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionExpiration {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionExpiration.epoch(
                Int(try Deserializer.u64(deserializer))
            )
        case 1:
            return TransactionExpiration.none
        default:
            throw SuiError.notImplemented
        }
    }
}

extension TransactionExpiration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else {
            let value = try container.decode(Int.self)
            self = .epoch(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .epoch(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
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
