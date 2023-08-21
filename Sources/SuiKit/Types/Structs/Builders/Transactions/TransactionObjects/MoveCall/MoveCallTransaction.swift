//
//  MoveCallTransaction.swift
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
import SwiftyJSON

public struct MoveCallTransaction: KeyProtocol, TransactionProtocol {
    public let target: SuiMoveNormalizedStructType
    public let typeArguments: [StructTag]
    public var arguments: [TransactionArgument]

    public init(
        target: SuiMoveNormalizedStructType,
        typeArguments: [StructTag],
        arguments: [TransactionArgument]
    ) {
        self.target = target
        self.typeArguments = typeArguments
        self.arguments = arguments
    }

    public init(
        target: String,
        typeArguments: [String],
        arguments: [TransactionArgument]
    ) throws {
        self.target = try Coin.getCoinStructTag(coinTypeArg: target)
        self.typeArguments = try typeArguments.map { try StructTag.fromStr($0) }
        self.arguments = arguments
    }

    public init?(input: JSON) {
        guard let target = SuiMoveNormalizedStructType(input: input) else {
            return nil
        }
        self.target = target
        self.typeArguments = []
        self.arguments = []
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: target)
        try serializer.sequence(self.typeArguments, Serializer._struct)
        try serializer.sequence(arguments, Serializer._struct)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> MoveCallTransaction {
        return MoveCallTransaction(
            target: try Deserializer._struct(deserializer),
            typeArguments: try deserializer.sequence(valueDecoder: Deserializer._struct),
            arguments: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    public func executeTransaction(
        objects: inout [ObjectsToResolve],
        inputs: inout [TransactionBlockInput]
    ) throws {
        return
    }

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
                            if case .input(let innerInput) = argumentInner,
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
