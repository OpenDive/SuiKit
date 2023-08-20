//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import SwiftyJSON

public struct MoveCallTransaction: KeyProtocol, TransactionProtocol {
    public let target: SuiMoveNormalizedStructType
    public let typeArguments: [StructTag]
    public var arguments: [TransactionArgument]

    public init(target: SuiMoveNormalizedStructType, typeArguments: [StructTag], arguments: [TransactionArgument]) {
        self.target = target
        self.typeArguments = typeArguments
        self.arguments = arguments
    }

    public init(target: String, typeArguments: [String], arguments: [TransactionArgument]) throws {
        self.target = try Coin.getCoinStructTag(coinTypeArg: target)
        self.typeArguments = try typeArguments.map { try StructTag.fromStr($0) }
        self.arguments = arguments
    }

    public init?(input: JSON) {
        guard let target = SuiMoveNormalizedStructType(input: input) else { return nil }
        self.target = target
        self.typeArguments = []
        self.arguments = []
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: target)
        try serializer.sequence(self.typeArguments, Serializer._struct)
        try serializer.sequence(arguments, Serializer._struct)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MoveCallTransaction {
        let target: SuiMoveNormalizedStructType = try Deserializer._struct(deserializer)
        let typeArgument: [StructTag] = try deserializer.sequence(valueDecoder: Deserializer._struct)
        let arguments: [TransactionArgument] = try deserializer.sequence(valueDecoder: Deserializer._struct)

        return MoveCallTransaction(
            target: target,
            typeArguments: typeArgument,
            arguments: arguments
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        return
    }

    public mutating func addToResolve(list: inout [MoveCallTransaction], inputs: [TransactionBlockInput]) throws {
        let needsResolution = self.arguments.contains { argument in
            switch argument {
            case .input(let transactionBlockInput):
                guard let value = inputs[Int(transactionBlockInput.index)].value else { return false }
                switch value {
                case .callArg:
                    return false
                default:
                    return true
                }
            default:
                return false
            }
        }

        if needsResolution {
            list.forEach { moveCall in
                for (idxOuter, argumentOuter) in self.arguments.enumerated() {
                    for (idxInner, argumentInner) in moveCall.arguments.enumerated() {
                        switch argumentOuter {
                        case .input(let outerInput):
                            switch argumentInner {
                            case .input(let innerInput):
                                if outerInput.value == innerInput.value && outerInput.index != innerInput.index {
                                    self.arguments[idxOuter] = moveCall.arguments[idxInner]
                                }
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }
                }
            }
            list.append(self)
        }
    }
}
