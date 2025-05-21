//
//  TransactionBlockDataBuilder.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
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
import Blake2

public struct TransactionBlockDataBuilder: KeyProtocol {
    /// Maximum allowed size for transaction data.
    public static let transactionDataMaxSize = 128 * 1024

    /// An instance of `SerializedTransactionDataBuilder` used to build transaction data.
    public var builder: SerializedTransactionDataBuilder

    /// Initializes a new instance of `TransactionBlockDataBuilder` with the provided `SerializedTransactionDataBuilder`.
    ///
    /// - Parameter builder: An instance of `SerializedTransactionDataBuilder`.
    public init(builder: SerializedTransactionDataBuilder) {
        self.builder = builder
    }

    /// Initializes a new instance of `TransactionBlockDataBuilder` with raw bytes.
    ///
    /// - Parameter bytes: A `Data` object containing the serialized transaction data.
    /// - Returns: An optional instance of `TransactionBlockDataBuilder`.
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

    /// Computes and returns the digest from the provided raw bytes.
    ///
    /// - Parameter bytes: A `Data` object.
    /// - Throws: If hashing fails.
    /// - Returns: A `String` representing the base58 encoded string of the hashed data.
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

    /// Restores and returns an instance of `TransactionBlockDataBuilder` from the provided `SerializedTransactionDataBuilder`.
    ///
    /// - Parameter data: An instance of `SerializedTransactionDataBuilder`.
    /// - Returns: An instance of `TransactionBlockDataBuilder`.
    public static func restore(
        data: SerializedTransactionDataBuilder
    ) -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(builder: data)
    }

    /// Builds and returns the serialized transaction data with the optional provided overrides and transaction kind.
    ///
    /// - Parameters:
    ///   - overrides: An optional instance of `TransactionBlockDataBuilder` containing the overrides.
    ///   - onlyTransactionKind: A `Bool` indicating whether to only use the transaction kind when building. Defaults to nil.
    /// - Throws: If missing required gas values or serialization fails.
    /// - Returns: A `Data` object representing the serialized transaction data.
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
            throw SuiError.customError(message: "Missing gas value")
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

    /// Computes and returns the digest of the built transaction data.
    ///
    /// - Throws: If building or hashing fails.
    /// - Returns: A `String` representing the base58 encoded string of the hashed data.
    public func getDigest() throws -> String {
        let bytes = try self.build()
        return try TransactionBlockDataBuilder.getDigestFromBytes(bytes: bytes)
    }

    /// Returns a snapshot of the current builder instance.
    ///
    /// - Returns: An instance of `SerializedTransactionDataBuilder`.
    public func snapshot() -> SerializedTransactionDataBuilder {
        return self.builder
    }

    /// Serializes the transaction block data builder.
    ///
    /// - Parameter serializer: An instance of `Serializer`.
    /// - Throws: If serialization fails.
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.builder)
    }

    /// Deserializes and returns an instance of `TransactionBlockDataBuilder`.
    ///
    /// - Parameter deserializer: An instance of `Deserializer`.
    /// - Throws: If deserialization fails.
    /// - Returns: An instance of `TransactionBlockDataBuilder`.
    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(builder: try Deserializer._struct(deserializer))
    }

    /// Prepares and returns a normalized SUI address from the provided address string.
    ///
    /// - Parameter address: A `String` representing the SUI address.
    /// - Throws: If address normalization fails.
    /// - Returns: A `String` representing the normalized SUI address.
    public func prepareSuiAddress(address: String) throws -> String {
        return try Inputs.normalizeSuiAddress(value: address).replacingOccurrences(of: "0x", with: "")
    }
}
