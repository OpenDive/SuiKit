//
//  TransactionBlockDataBuilder.swift
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
import CryptoKit
import Web3Core
import Blake2

public struct TransactionBlockDataBuilder: KeyProtocol {
    public static let transactionDataMaxSize = 128 * 1024

    public var builder: SerializedTransactionDataBuilder

    public init(builder: SerializedTransactionDataBuilder) {
        self.builder = builder
    }

    public init?(bytes: Data) {
        let der = Deserializer(data: bytes)
        guard let transactionData: TransactionData = try? Deserializer._struct(der) else {
            return nil
        }
        switch transactionData {
        case .V1(let v1Data):
            guard let builder = SerializedTransactionDataBuilder(
                v1Transaction: v1Data
            ) else { return nil }
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

        let hashedData = try Blake2b.hash(size: 32, data: Data(dataWithTag))
        let hash = Array(hashedData)

        return hash.base58EncodedString
    }

    public static func restore(
        data: SerializedTransactionDataBuilder
    ) -> TransactionBlockDataBuilder {
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
            throw SuiError.missingGasValues
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
            expiration: expiration ?? TransactionExpiration.none
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

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(builder: try Deserializer._struct(deserializer))
    }

    public func prepareSuiAddress(address: String) throws -> String {
        return try Inputs.normalizeSuiAddress(value: address).replacingOccurrences(of: "0x", with: "")
    }
}
