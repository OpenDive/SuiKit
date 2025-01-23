//
//  SplitCoinsTransaction.swift
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

public struct SplitCoinsTransaction: KeyProtocol, TransactionProtocol {
    /// A `TransactionArgument` representing the coin to be split.
    public var coin: TransactionArgument

    /// An array of `TransactionArgument` representing the amounts in which the coin will be split.
    public var amounts: [TransactionArgument]

    /// Initializes a new instance of `SplitCoinsTransaction`.
    /// - Parameters:
    ///   - coin: A `TransactionArgument` representing the coin.
    ///   - amounts: An array of `TransactionArgument` representing the amounts.
    public init(
        coin: TransactionArgument,
        amounts: [TransactionArgument]
    ) {
        self.coin = coin
        self.amounts = amounts
    }

    /// Initializes a new instance of `SplitCoinsTransaction` using a JSON object.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `SplitCoinsTransaction`.
    public init?(input: JSON) {
        let split = input.arrayValue
        guard let coin = TransactionArgument.fromJSON(split[0]) else {
            return nil
        }
        self.coin = coin
        self.amounts = split[1].arrayValue.compactMap {
            TransactionArgument.fromJSON($0)
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: coin)
        try serializer.sequence(amounts, Serializer._struct)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            coin: try Deserializer._struct(deserializer),
            amounts: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
