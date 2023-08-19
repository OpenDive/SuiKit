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
    public let arguments: [TransactionArgument]

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
        return MoveCallTransaction(
            target: try Deserializer._struct(deserializer),
            typeArguments: try deserializer.sequence(valueDecoder: Deserializer._struct),
            arguments: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        return
    }

    public func addToResolve(list: inout [MoveCallTransaction], inputs: [TransactionBlockInput]) throws {
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
            list.append(self)
        }
    }
}
