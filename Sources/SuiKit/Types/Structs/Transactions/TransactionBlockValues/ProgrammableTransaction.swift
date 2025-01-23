//
//  ProgrammableTransaction.swift
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

public struct ProgrammableTransaction: KeyProtocol {
    /// Array representing the inputs of the programmable transaction.
    public let inputs: [Input]

    /// Array containing the `SuiTransaction` instances associated with the programmable transaction.
    public let transactions: [SuiTransaction]

    public init(inputs: [Input], transactions: [SuiTransaction]) {
        self.inputs = inputs
        self.transactions = transactions
    }

    public init(input: JSON) {
        self.inputs = input["inputs"].arrayValue.compactMap { Input(input: $0) }
        self.transactions = input["transactions"].arrayValue.compactMap { SuiTransaction.fromJSON($0) }
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(inputs, Serializer._struct)
        try serializer.sequence(transactions, Serializer._struct)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ProgrammableTransaction {
        let inputs: [Input] = try deserializer.sequence(valueDecoder: Deserializer._struct)
        let transactions: [SuiTransaction] = try deserializer.sequence(valueDecoder: Deserializer._struct)
        return ProgrammableTransaction(
            inputs: inputs,
            transactions: transactions
        )
    }
}
