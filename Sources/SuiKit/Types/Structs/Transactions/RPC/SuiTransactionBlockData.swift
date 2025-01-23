//
//  SuiTransactionBlockData.swift
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
import SwiftyJSON

public struct SuiTransactionBlockData: KeyProtocol {
    /// A `String` representing the message version of the transaction block data.
    public let messageVersion: String

    /// A `SuiTransactionBlockKind` representing the kind or type of the transaction block.
    public let transaction: SuiTransactionBlockKind

    /// An `AccountAddress` representing the sender of the transaction block.
    public let sender: AccountAddress

    /// A `SuiGasData` representing the gas data associated with the transaction block.
    public let gasData: SuiGasData

    public init(
        messageVersion: String,
        transaction: SuiTransactionBlockKind,
        sender: AccountAddress,
        gasData: SuiGasData
    ) {
        self.messageVersion = messageVersion
        self.transaction = transaction
        self.sender = sender
        self.gasData = gasData
    }

    public init?(input: JSON) {
        guard let transaction = SuiTransactionBlockKind.fromJSON(input["transaction"]) else { return nil }
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        guard let gasData = SuiGasData(input: input["gasData"]) else { return nil }
        self.messageVersion = input["messageVersion"].stringValue
        self.transaction = transaction
        self.sender = sender
        self.gasData = gasData
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.messageVersion)
        try Serializer._struct(serializer, value: self.transaction)
        try Serializer._struct(serializer, value: self.sender)
        try Serializer._struct(serializer, value: self.gasData)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransactionBlockData {
        return SuiTransactionBlockData(
            messageVersion: try Deserializer.string(deserializer),
            transaction: try Deserializer._struct(deserializer),
            sender: try Deserializer._struct(deserializer),
            gasData: try Deserializer._struct(deserializer)
        )
    }
}
