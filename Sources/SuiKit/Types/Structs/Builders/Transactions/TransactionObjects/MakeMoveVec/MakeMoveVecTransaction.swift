//
//  MakeMoveVecTransaction.swift
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

public struct MakeMoveVecTransaction: KeyProtocol, TransactionProtocol {
    /// An array of TransactionArguments representing objects involved in the transaction.
    public let objects: [TransactionArgument]

    /// Represents the type of Move Normalized Struct. It's optional and could be nil.
    public let type: SuiMoveNormalizedStructType?

    /// Initializes a new instance of `MakeMoveVecTransaction`.
    /// - Parameters:
    ///   - objects: An array of `TransactionArgument` representing objects in the transaction.
    ///   - type: A string representing the type of `SuiMoveNormalizedStructType`.
    /// - Throws: If initialization fails due to type conversion.
    public init(objects: [TransactionArgument], type: String?) throws {
        self.objects = objects
        if let type = type {
            self.type = try Coin.getCoinStructTag(coinTypeArg: type)
        } else {
            self.type = nil
        }
    }

    /// Initializes a new instance of `MakeMoveVecTransaction`.
    /// - Parameters:
    ///   - objects: An array of `TransactionArgument` representing objects in the transaction.
    ///   - type: An optional instance of `SuiMoveNormalizedStructType`.
    public init(objects: [TransactionArgument], type: SuiMoveNormalizedStructType?) {
        self.objects = objects
        self.type = type
    }

    /// Initializes a new instance of `MakeMoveVecTransaction` from JSON.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `MakeMoveVecTransaction`.
    public init?(input: JSON) {
        let vec = input.arrayValue
        self.objects = vec[0].arrayValue.compactMap { TransactionArgument.fromJSON($0) }
        self.type = try? Coin.getCoinStructTag(coinTypeArg: vec[1].stringValue)
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(0)
        try serializer.sequence(objects, Serializer._struct)
        if let type { try Serializer._struct(serializer, value: type) }
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> MakeMoveVecTransaction {
        _ = Deserializer.uleb128(deserializer)
        return MakeMoveVecTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            type: try? Deserializer._struct(deserializer)
        )
    }
}
