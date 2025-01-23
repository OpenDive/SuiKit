//
//  MergeCoinsTransaction.swift
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

public struct MergeCoinsTransaction: KeyProtocol, TransactionProtocol {
    /// The destination where the coins are to be merged.
    public let destination: TransactionArgument

    /// An array of sources from which the coins are taken to be merged.
    public let sources: [TransactionArgument]

    /// Initializes a new instance of `MergeCoinsTransaction`.
    /// - Parameters:
    ///   - destination: The destination argument where the coins are to be merged.
    ///   - sources: An array of source arguments from which the coins are taken to be merged.
    public init(destination: TransactionArgument, sources: [TransactionArgument]) {
        self.destination = destination
        self.sources = sources
    }

    /// Initializes a new instance of `MergeCoinsTransaction` from JSON.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `MergeCoinsTransaction`.
    public init?(input: JSON) {
        let merge = input.arrayValue
        guard let destination = TransactionArgument.fromJSON(merge[0]) else { return nil }
        self.destination = destination
        self.sources = merge[1].arrayValue.compactMap { TransactionArgument.fromJSON($0) }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: destination)
        try serializer.sequence(sources, Serializer._struct)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            destination: try Deserializer._struct(deserializer),
            sources: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
