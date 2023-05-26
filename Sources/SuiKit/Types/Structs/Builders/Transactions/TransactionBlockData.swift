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
    
    // TODO: Implement build() function
    public func build(
        overrides: TransactionBlockDataBuilder? = nil,
        onlyTransactionKind: Bool? = nil
    ) {
        
    }
    
    // TODO: Implement getDigest() function
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
