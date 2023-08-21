//
//  SerializedTransactionDataBuilder.swift
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

public struct SerializedTransactionDataBuilder: KeyProtocol {
    public var version: UInt8
    public var sender: AccountAddress?
    public var expiration: TransactionExpiration?
    public var gasConfig: SuiGasData
    public var inputs: [TransactionBlockInput]
    public var transactions: [SuiTransaction]

    public enum CodingKeys: String, CodingKey {
        case version
        case sender
        case expiration
        case gasConfig
        case inputs
        case transactions
    }

    public init(
        version: UInt8 = 1,
        sender: AccountAddress? = nil,
        expiration: TransactionExpiration? = TransactionExpiration.none(true),
        gasConfig: SuiGasData? = nil,
        inputs: [TransactionBlockInput] = [],
        transactions: [SuiTransaction] = []
    ) throws {
        self.version = version
        self.sender = sender
        self.expiration = expiration
        self.gasConfig = gasConfig ?? SuiGasData()
        self.inputs = inputs
        self.transactions = transactions
    }

    public init?(v1Transaction: TransactionDataV1) {
        switch v1Transaction.kind {
        case .programmableTransaction(let programTx):
            self.version = 1
            self.sender = v1Transaction.sender
            self.expiration = v1Transaction.expiration
            self.gasConfig = v1Transaction.gasData
            self.inputs = programTx.inputs.enumerated().map { (idx, input) in
                TransactionBlockInput(
                    index: UInt16(idx),
                    value: .callArg(input),
                    type: input.kind == "pure" ? .pure : .object
                )
            }
            self.transactions = programTx.transactions
        default:
            return nil
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, self.version)
        if let sender { try Serializer.str(serializer, sender) }
        if let expiration { try Serializer._struct(serializer, value: expiration) }
        try Serializer._struct(serializer, value: gasConfig)
        try serializer.sequence(self.inputs, Serializer._struct)
        try serializer.sequence(self.transactions, Serializer._struct)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> SerializedTransactionDataBuilder {
        return try SerializedTransactionDataBuilder(
            version: try Deserializer.u8(deserializer),
            sender: try? Deserializer._struct(deserializer),
            expiration: try? Deserializer._struct(deserializer),
            gasConfig: try? Deserializer._struct(deserializer),
            inputs: try deserializer.sequence(valueDecoder: Deserializer._struct),
            transactions: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
