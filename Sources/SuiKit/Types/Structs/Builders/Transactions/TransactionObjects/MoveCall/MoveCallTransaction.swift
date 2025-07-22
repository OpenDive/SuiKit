//
//  MoveCallTransaction.swift
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

public struct MoveCallTransaction: KeyProtocol, TransactionProtocol {
    /// The target normalized struct type for the move call.
    public let target: SuiMoveNormalizedStructType

    /// An array of type tags used as type arguments for the move call.
    public let typeArguments: [TypeTag]

    /// An array of arguments used for executing the move call.
    public var arguments: [TransactionArgument]

    /// Initializes a new instance of `MoveCallTransaction`.
    /// - Parameters:
    ///   - target: The target normalized struct type.
    ///   - typeArguments: An array of type tags used as type arguments.
    ///   - arguments: An array of transaction arguments.
    public init(
        target: SuiMoveNormalizedStructType,
        typeArguments: [StructTag],
        arguments: [TransactionArgument]
    ) throws {
        self.target = target
        self.typeArguments = try typeArguments.map { try .init(value: $0) }
        self.arguments = arguments
    }

    /// Initializes a new instance of `MoveCallTransaction` using string representations.
    /// - Parameters:
    ///   - target: The string representation of the target normalized struct type.
    ///   - typeArguments: An array of string representations of type tags used as type arguments.
    ///   - arguments: An array of transaction arguments.
    /// - Throws: If creating struct tags from strings fails.
    public init(
        target: String,
        typeArguments: [String],
        arguments: [TransactionArgument]
    ) throws {
        self.target = try Coin.getCoinStructTag(coinTypeArg: target)
        self.typeArguments = try typeArguments.map { try .init(stringValue: $0) }
        self.arguments = arguments
    }

    /// Initializes a new instance of `MoveCallTransaction` from JSON.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `MoveCallTransaction`.
    public init?(input: JSON) {
        guard let target = SuiMoveNormalizedStructType(input: input) else {
            return nil
        }
        self.target = target
        self.typeArguments = []
        self.arguments = []
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.target)
        try serializer.sequence(self.typeArguments, Serializer._struct)
        try serializer.sequence(self.arguments, Serializer._struct)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> MoveCallTransaction {
        return try MoveCallTransaction(
            target: try Deserializer._struct(deserializer),
            typeArguments: try deserializer.sequence(valueDecoder: Deserializer._struct),
            arguments: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    /// Adds to resolve list if needed, based on the arguments and provided inputs.
    /// - Parameters:
    ///   - list: A reference to an array of `MoveCallTransaction` to which the current instance may be appended.
    ///   - inputs: An array of `TransactionBlockInput` used for resolving the arguments.
    /// - Throws: If resolving fails.
    public mutating func addToResolve(
        list: inout [MoveCallTransaction],
        inputs: [TransactionBlockInput]
    ) throws {
        let needsResolution = self.arguments.contains { argument in
            if case .input(let transactionBlockInput) = argument,
               let value = inputs[Int(transactionBlockInput.index)].value {
                if case .callArg = value {
                    return false
                }
                return true
            }
            return false
        }

        if needsResolution {
            list.forEach { moveCall in
                for (idxOuter, argumentOuter) in self.arguments.enumerated() {
                    if case .input(let outerInput) = argumentOuter {
                        for (idxInner, argumentInner) in moveCall.arguments.enumerated() {
                            if
                                case .input(let innerInput) = argumentInner,
                                outerInput.value == innerInput.value,
                                outerInput.index != innerInput.index {
                                self.arguments[idxOuter] = moveCall.arguments[idxInner]
                            }
                        }
                    }
                }
            }
            list.append(self)
        }
    }
}
