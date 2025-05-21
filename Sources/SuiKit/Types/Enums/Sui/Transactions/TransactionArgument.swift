//
//  ProtocolConfigValue.swift
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

/// Represents the different types of arguments that can be involved in a transaction.
public enum TransactionArgument: KeyProtocol {
    /// Represents the gas coin for the transaction.
    case gasCoin

    /// Represents the input block for the transaction.
    case input(TransactionBlockInput)

    /// Represents the result of the transaction.
    case result(Result)

    /// Represents a nested result within a transaction.
    case nestedResult(NestedResult)

    /// Returns the kind of transaction argument.
    public var kind: TransactionArgumentName {
        switch self {
        case .gasCoin:
            return .gasCoin
        case .input:
            return .input
        case .result:
            return .result
        case .nestedResult:
            return .nestedResult
        }
    }

    /// Creates a `TransactionArgument` from a JSON object.
    ///
    /// - Parameter input: The JSON object to parse.
    /// - Returns: A `TransactionArgument` if successful, otherwise `nil`.
    public static func fromJSON(_ input: JSON) -> TransactionArgument? {
        if input["Input"].exists() {
            return .input(TransactionBlockInput(index: input["Input"].uInt16Value))
        }
        if input["GasCoin"].exists() {
            return .gasCoin
        }
        if input["Result"].exists() {
            return .result(Result(index: input["Result"].uInt16Value))
        }
        if input["NestedResult"].exists() {
            let nestedResult = input["NestedResult"].arrayValue
            return .nestedResult(
                NestedResult(
                    index: nestedResult[0].uInt16Value,
                    resultIndex: nestedResult[1].uInt16Value
                )
            )
        }
        return nil
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .gasCoin:
            try Serializer.u8(serializer, UInt8(0))
        case .input(let transactionBlockInput):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: transactionBlockInput)
        case .result(let result):
            try Serializer.u8(serializer, UInt8(2))
            try Serializer._struct(serializer, value: result)
        case .nestedResult(let nestedResult):
            try Serializer.u8(serializer, UInt8(3))
            try Serializer._struct(serializer, value: nestedResult)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgument {
        let type = try Deserializer.u8(deserializer)

        switch type {
        case 0:
            return TransactionArgument.gasCoin
        case 1:
            return TransactionArgument.input(try Deserializer._struct(deserializer))
        case 2:
            return TransactionArgument.result(try Deserializer._struct(deserializer))
        case 3:
            return TransactionArgument.nestedResult(try Deserializer._struct(deserializer))
        default:
            throw SuiError.customError(message: "Unable to Deserialize")
        }
    }
}
