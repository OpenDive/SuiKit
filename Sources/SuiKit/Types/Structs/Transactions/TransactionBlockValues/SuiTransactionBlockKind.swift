//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum TransactionKindName: String {
    case programmableTransaction = "ProgrammableTransaction"
    case changeEpoch = "ChangeEpoch"
    case genesis = "Genesis"
    case consensusCommitPrologue = "ConsensusCommitPrologue"
}

public enum SuiTransactionBlockKind: KeyProtocol {
    case programmableTransaction(ProgrammableTransaction)
    case changeEpoch(SuiChangeEpoch)
    case genesis(Genesis)
    case consensusCommitPrologue(SuiConsensusCommitPrologue)

    public static func fromJSON(_ input: JSON) -> SuiTransactionBlockKind? {
        switch input["kind"].stringValue {
        case "ProgrammableTransaction":
            return .programmableTransaction(ProgrammableTransaction(input: input))
        case "ChangeEpoch":
            return .changeEpoch(SuiChangeEpoch(input: input))
        case "Genesis":
            return .genesis(Genesis(input: input))
        case "ConsensusCommitPrologue":
            return .consensusCommitPrologue(SuiConsensusCommitPrologue(input: input))
        default:
            return nil
        }
    }

    public func kind() -> TransactionKindName {
        switch self {
        case .programmableTransaction:
            return .programmableTransaction
        case .changeEpoch:
            return .changeEpoch
        case .genesis:
            return .genesis
        case .consensusCommitPrologue:
            return .consensusCommitPrologue
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .programmableTransaction(let programmableTransaction):
            try Serializer.u8(serializer, UInt8(0))
            try Serializer._struct(serializer, value: programmableTransaction)
        case .changeEpoch(let suiChangeEpoch):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: suiChangeEpoch)
        case .genesis(let genesis):
            try Serializer.u8(serializer, UInt8(2))
            try Serializer._struct(serializer, value: genesis)
        case .consensusCommitPrologue(let suiConsensusCommitPrologue):
            try Serializer.u8(serializer, UInt8(3))
            try Serializer._struct(serializer, value: suiConsensusCommitPrologue)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransactionBlockKind {
        let type = try Deserializer.u8(deserializer)

        switch type {
        case 0:
            return .programmableTransaction(try Deserializer._struct(deserializer))
        case 1:
            return .changeEpoch(try Deserializer._struct(deserializer))
        case 2:
            return .genesis(try Deserializer._struct(deserializer))
        case 3:
            return .consensusCommitPrologue(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }
}
