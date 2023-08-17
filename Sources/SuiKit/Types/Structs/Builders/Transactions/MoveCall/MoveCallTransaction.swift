//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation

public struct MoveCallTransaction: KeyProtocol, TransactionProtocol {
    public let target: String
    public let typeArguments: [String]
    public let arguments: [TransactionArgument]
    
    public func serialize(_ serializer: Serializer) throws {
        let normalizedModule = try Coin.getCoinStructTag(coinTypeArg: self.target)
        let address = try ED25519PublicKey(hexString: normalizedModule.address)
        address.serializeModule(serializer)
        try Serializer.str(serializer, normalizedModule.module)
        try Serializer.str(serializer, normalizedModule.name)
        let structs = try typeArguments.map { try StructTag.fromStr($0) }
        try serializer.sequence(structs, Serializer._struct)
        try serializer.sequence(arguments, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MoveCallTransaction {
        throw SuiError.notImplemented
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
