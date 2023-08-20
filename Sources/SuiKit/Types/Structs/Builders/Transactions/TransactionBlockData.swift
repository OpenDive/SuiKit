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
import Blake2

public struct TransactionBlockDataBuilder: KeyProtocol {
    public static let transactionDataMaxSize = 128 * 1024

    public var builder: SerializedTransactionDataBuilder

    public init(builder: SerializedTransactionDataBuilder) {
        self.builder = builder
    }

    public init?(bytes: Data) {
        let der = Deserializer(data: bytes)
        guard let transactionData: TransactionData = try? Deserializer._struct(der) else { return nil }
        switch transactionData {
        case .V1(let v1Data):
            guard let builder = SerializedTransactionDataBuilder(v1Transaction: v1Data) else { return nil }
            self.builder = builder
        }
    }

    public static func getDigestFromBytes(bytes: Data) throws -> String {
        let typeTag = "TransactionData"
        let data: Data = bytes
        let typeTagBytes = Array(typeTag.utf8) + Array("::".utf8)
        
        var dataWithTag = [UInt8]()
        dataWithTag.append(contentsOf: typeTagBytes)
        dataWithTag.append(contentsOf: data)
        
        let hashedData = try Blake2.hash(.b2b, size: 32, data: Data(dataWithTag))
        
        let hash = Array(hashedData)
        return Base58.base58Encode(hash)
    }

    public static func restore(data: SerializedTransactionDataBuilder) -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(builder: data)
    }

    public func build(
        overrides: TransactionBlockDataBuilder? = nil,
        onlyTransactionKind: Bool? = nil
    ) throws -> Data {
        let inputs = self.builder.inputs.compactMap { value in
            switch value.value {
            case .callArg(let callArg):
                return callArg
            default:
                return nil
            }
        }
        let transactions = self.builder.transactions
        let kind = ProgrammableTransaction(inputs: inputs, transactions: transactions)

        if let onlyTransactionKind, onlyTransactionKind {
            let ser = Serializer()
            try SuiTransactionBlockKind.programmableTransaction(kind).serialize(ser)
            return ser.output()
        }

        let expiration = overrides?.builder.expiration ?? self.builder.expiration
        let senderUnwrapped = overrides?.builder.sender ?? self.builder.sender
        let gasConfig = overrides?.builder.gasConfig ?? self.builder.gasConfig

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
            sender: sender,
            gasData: try SuiGasData(
                payment: payment,
                owner: prepareSuiAddress(
                    address: self.builder.gasConfig.owner?.hex() ?? sender.hex()
                ),
                price: price,
                budget: budget
            ),
            expiration: expiration ?? TransactionExpiration.none(true)
        ))

        let ser = Serializer()
        try transactionData.serialize(ser)
        return ser.output()
    }

    public func getDigest() throws -> String {
        let bytes = try self.build()
        return try TransactionBlockDataBuilder.getDigestFromBytes(bytes: bytes)
    }

    public func snapshot() -> SerializedTransactionDataBuilder {
        return self.builder
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.builder)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(builder: try Deserializer._struct(deserializer))
    }

    public func prepareSuiAddress(address: String) throws -> String {
        return try Inputs.normalizeSuiAddress(value: address).replacingOccurrences(of: "0x", with: "")
    }
}
