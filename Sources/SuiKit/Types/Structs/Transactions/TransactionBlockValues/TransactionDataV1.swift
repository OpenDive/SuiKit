//
//  TransactionDataV1.swift
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

public struct TransactionDataV1: KeyProtocol {
    /// A value indicating the kind/type of the transaction block.
    public let kind: SuiTransactionBlockKind

    /// A value representing the account address of the sender of the transaction.
    public let sender: AccountAddress

    /// A value containing information regarding the gas used by the transaction.
    public let gasData: SuiGasData

    /// A value representing the expiration details of the transaction.
    public let expiration: TransactionExpiration

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.kind)
        try Serializer._struct(serializer, value: self.sender)
        try Serializer._struct(serializer, value: self.gasData)
        try Serializer._struct(serializer, value: self.expiration)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionDataV1 {
        return TransactionDataV1(
            kind: try Deserializer._struct(deserializer),
            sender: try Deserializer._struct(deserializer),
            gasData: try Deserializer._struct(deserializer),
            expiration: try Deserializer._struct(deserializer)
        )
    }
}
