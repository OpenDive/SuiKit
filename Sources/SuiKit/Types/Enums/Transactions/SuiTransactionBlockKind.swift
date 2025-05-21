//
//  SuiTransactionBlockKind.swift
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

/// Enum representing different kinds of transaction blocks in the Sui framework.
public enum SuiTransactionBlockKind: KeyProtocol {
    /// A block for a programmable transaction.
    case programmableTransaction(ProgrammableTransaction)

    /// A block for changing epochs.
    case changeEpoch(SuiChangeEpoch)

    /// A block for initializing the chain's state.
    case genesis(Genesis)

    /// A block for handling consensus commit prologues.
    case consensusCommitPrologue(SuiConsensusCommitPrologue)

    /// Initializes a `SuiTransactionBlockKind` from a JSON object.
    /// Returns `nil` if the kind specified in the JSON doesn't match any of the supported kinds.
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

    /// Returns the kind of transaction block.
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
            throw SuiError.customError(message: "Unable to Deserialize")
        }
    }
}
