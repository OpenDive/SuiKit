//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import AnyCodable
import BigInt
import SwiftyJSON

public typealias EpochId = String
public typealias SequenceNumber = String
public typealias ObjectDigest = String
public typealias AuthoritySignature = String
public typealias TransactionEventDigest = String
public typealias ReturnValueType = ([UInt8], String)
public typealias TransactionEvents = [SuiEvent]
public typealias MutableReferenceOutputType = (TransactionArgument, [UInt8], String)
public typealias EmptySignInfo = [String: AnyCodable]
public typealias AuthorityName = String

public struct SuiChangeEpoch: Codable, KeyProtocol {
    public let epoch: EpochId
    public let storageCharge: String
    public let computationCharge: String
    public let storageRebate: String
    public let epochStartTimestampMs: String?
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, epoch)
        try Serializer.str(serializer, storageCharge)
        try Serializer.str(serializer, computationCharge)
        try Serializer.str(serializer, storageRebate)
        
        if let epochStartTimestampMs {
            try Serializer.str(serializer, epochStartTimestampMs)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiChangeEpoch {
        return SuiChangeEpoch(
            epoch: try Deserializer.string(deserializer),
            storageCharge: try Deserializer.string(deserializer),
            computationCharge: try Deserializer.string(deserializer),
            storageRebate: try Deserializer.string(deserializer),
            epochStartTimestampMs: try Deserializer.string(deserializer)
        )
    }
}

public struct SuiConsensusCommitPrologue: Codable, KeyProtocol {
    public let epoch: EpochId
    public let round: String
    public let commitTimestampMs: String
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, epoch)
        try Serializer.str(serializer, round)
        try Serializer.str(serializer, commitTimestampMs)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiConsensusCommitPrologue {
        return SuiConsensusCommitPrologue(
            epoch: try Deserializer.string(deserializer),
            round: try Deserializer.string(deserializer),
            commitTimestampMs: try Deserializer.string(deserializer)
        )
    }
}

public struct Genesis: Codable, KeyProtocol {
    public let objects: [objectId]
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(objects, Serializer.str)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Genesis {
        return Genesis(objects: try deserializer.sequence(valueDecoder: Deserializer.string))
    }
}

public struct MoveCallSuiTransaction: Codable, KeyProtocol {
    public let arguments: [TransactionArgument]?
    public let typeArguments: [String]?
    public let package: objectId
    public let module: String
    public let function: String
    
    public func serialize(_ serializer: Serializer) throws {
        if let arguments {
            try serializer.sequence(arguments, Serializer._struct)
        }
        if let typeArguments {
            try serializer.sequence(typeArguments, Serializer.str)
        }
        try Serializer.str(serializer, package)
        try Serializer.str(serializer, module)
        try Serializer.str(serializer, function)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MoveCallSuiTransaction {
        return MoveCallSuiTransaction(
            arguments: try deserializer.sequence(valueDecoder: TransactionArgument.deserialize),
            typeArguments: try deserializer.sequence(valueDecoder: Deserializer.string),
            package: try Deserializer.string(deserializer),
            module: try Deserializer.string(deserializer),
            function: try Deserializer.string(deserializer)
        )
    }
}

public enum SuiTransaction: Codable, KeyProtocol, TransactionTypesProtocol {
    case moveCall(MoveCallTransaction)
    case transferObjects(TransferObjectsTransaction)
    case splitCoins(SplitCoinsTransaction)
    case mergeCoins(MergeCoinsTransaction)
    case publish(PublishTransaction)
    case upgrade(UpgradeTransaction)
    case makeMoveVec(MakeMoveVecTransaction)
    
    public var kind: String {
        switch self {
        case .moveCall:
            return "MoveCall"
        case .transferObjects:
            return "TransferObject"
        case .splitCoins:
            return "SplitCoin"
        case .mergeCoins:
            return "MergeCoin"
        case .publish:
            return "Publish"
        case .upgrade:
            return "Upgrade"
        case .makeMoveVec:
            return "MakeMoveVec"
        }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .moveCall(let moveCallSuiTransaction):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: moveCallSuiTransaction)
        case .transferObjects(let transferObjectsTransaction):
            try Serializer.u8(serializer, 1)
            try Serializer._struct(serializer, value: transferObjectsTransaction)
        case .splitCoins(let splitCoinsTransaction):
            try Serializer.u8(serializer, 2)
            try Serializer._struct(serializer, value: splitCoinsTransaction)
        case .mergeCoins(let mergeCoinsTransaction):
            try Serializer.u8(serializer, 3)
            try Serializer._struct(serializer, value: mergeCoinsTransaction)
        case .publish(let publishTransaction):
            try Serializer.u8(serializer, 4)
            try Serializer._struct(serializer, value: publishTransaction)
        case .upgrade(let upgradeTransaction):
            try Serializer.u8(serializer, 5)
            try Serializer._struct(serializer, value: upgradeTransaction)
        case .makeMoveVec(let makeMoveVecTransaction):
            try Serializer.u8(serializer, 6)
            try Serializer._struct(serializer, value: makeMoveVecTransaction)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransaction {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return SuiTransaction.moveCall(
                try Deserializer._struct(deserializer)
            )
        case 1:
            return SuiTransaction.transferObjects(
                try Deserializer._struct(deserializer)
            )
        case 2:
            return SuiTransaction.splitCoins(
                try Deserializer._struct(deserializer)
            )
        case 3:
            return SuiTransaction.mergeCoins(
                try Deserializer._struct(deserializer)
            )
        case 4:
            return SuiTransaction.publish(
                try Deserializer._struct(deserializer)
            )
        case 5:
            return SuiTransaction.upgrade(
                try Deserializer._struct(deserializer)
            )
        case 6:
            return SuiTransaction.makeMoveVec(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public enum PublishType: Codable, KeyProtocol {
    case oldType(SuiMovePackage, [objectId])
    case newType([objectId])
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .oldType(let suiMovePackage, let array):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: suiMovePackage)
            try serializer.sequence(array, Serializer.str)
        case .newType(let array):
            try Serializer.u8(serializer, 1)
            try serializer.sequence(array, Serializer.str)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PublishType {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return PublishType.oldType(
                try Deserializer._struct(deserializer),
                try deserializer.sequence(valueDecoder: Deserializer.string)
            )
        case 1:
            return PublishType.newType(
                try deserializer.sequence(valueDecoder: Deserializer.string)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public enum UpgradeType: Codable, KeyProtocol {
    case oldType(SuiMovePackage, [objectId], objectId, TransactionArgument)
    case newType([objectId], objectId, TransactionArgument)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .oldType(let suiMovePackage, let array, let objectId, let suiArgument):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: suiMovePackage)
            try serializer.sequence(array, Serializer.str)
            try Serializer.str(serializer, objectId)
            try Serializer._struct(serializer, value: suiArgument)
        case .newType(let array, let objectId, let suiArgument):
            try Serializer.u8(serializer, 1)
            try serializer.sequence(array, Serializer.str)
            try Serializer.str(serializer, objectId)
            try Serializer._struct(serializer, value: suiArgument)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> UpgradeType {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return UpgradeType.oldType(
                try Deserializer._struct(deserializer),
                try deserializer.sequence(valueDecoder: Deserializer.string),
                try Deserializer.string(deserializer),
                try Deserializer._struct(deserializer)
            )
        case 1:
            return UpgradeType.newType(
                try deserializer.sequence(valueDecoder: Deserializer.string),
                try Deserializer.string(deserializer),
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public enum SuiCallArg: Codable, KeyProtocol {
    case pure(PureSuiCallArg)
    case ownedObject(OwnedObjectSuiCallArg)
    case sharedObject(SharedObjectSuiCallArg)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .pure(let pureSuiCallArg):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: pureSuiCallArg)
        case .ownedObject(let ownedObjectSuiCallArg):
            try Serializer.u8(serializer, 1)
            try Serializer._struct(serializer, value: ownedObjectSuiCallArg)
        case .sharedObject(let sharedObjectSuiCallArg):
            try Serializer.u8(serializer, 2)
            try Serializer._struct(serializer, value: sharedObjectSuiCallArg)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiCallArg {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return SuiCallArg.pure(try Deserializer._struct(deserializer))
        case 1:
            return SuiCallArg.ownedObject(try Deserializer._struct(deserializer))
        case 2:
            return SuiCallArg.sharedObject(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct PureSuiCallArg: Codable, KeyProtocol {
    public let type: String
    public let valueType: String?
    public let value: SuiJsonValue
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, type)
        if let valueType { try Serializer.str(serializer, valueType) }
        try Serializer._struct(serializer, value: value)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PureSuiCallArg {
        return PureSuiCallArg(
            type: try Deserializer.string(deserializer),
            valueType: try Deserializer.string(deserializer),
            value: try Deserializer._struct(deserializer)
        )
    }
}

public enum SuiJsonValueType: String {
    case boolean
    case number
    case string
    case callArg
    case array
    case data
    case input
}

public indirect enum SuiJsonValue: Codable, KeyProtocol {
    case boolean(Bool)
    case number(UInt64)
    case string(String)
    case callArg(SuiCallArg)
    case array([SuiJsonValue])
    case data(Data)
    case input(TransactionBlockInput)
    
    // TODO: Create fromJSONObject function
//    public static func fromJSONObject(_ data: JSON, _ type: String) throws -> SuiJsonValue {
//        let valueType 
//    }
    
    public var kind: SuiJsonValueType {
        switch self {
        case .boolean:
            return .boolean
        case .number:
            return .number
        case .string:
            return .string
        case .callArg:
            return .callArg
        case .array:
            return .array
        case .data:
            return .array
        case .input:
            return .input
        }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .boolean(let bool):
            try Serializer.u8(serializer, 0)
            try Serializer.bool(serializer, bool)
        case .number(let uint64):
            try Serializer.u8(serializer, 1)
            try Serializer.u64(serializer, uint64)
        case .string(let string):
            try Serializer.u8(serializer, 2)
            try Serializer.str(serializer, string)
        case .callArg(let callArg):
            try Serializer.u8(serializer, 3)
            try Serializer._struct(serializer, value: callArg)
        case .array(let array):
            try Serializer.u8(serializer, 4)
            try serializer.sequence(array, Serializer._struct)
        case .data(let data):
            try Serializer.u8(serializer, 5)
            serializer.fixedBytes(data)
        case .input(let txInput):
            try Serializer.u8(serializer, 6)
            try Serializer._struct(serializer, value: txInput)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiJsonValue {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return SuiJsonValue.boolean(try deserializer.bool())
        case 1:
            return SuiJsonValue.number(try Deserializer.u64(deserializer))
        case 2:
            return SuiJsonValue.string(try Deserializer.string(deserializer))
        case 3:
            return SuiJsonValue.callArg(try Deserializer._struct(deserializer))
        case 4:
            return SuiJsonValue.array(try deserializer.sequence(valueDecoder: Deserializer._struct))
        case 5:
            return SuiJsonValue.data(try Deserializer.toBytes(deserializer))
        case 6:
            return SuiJsonValue.input(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct OwnedObjectSuiCallArg: Codable, KeyProtocol {
    public let type: String
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, type)
        try Serializer.str(serializer, objectType)
        try Serializer.str(serializer, objectId)
        try Serializer.str(serializer, version)
        try Serializer.str(serializer, digest)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> OwnedObjectSuiCallArg {
        return OwnedObjectSuiCallArg(
            type: try Deserializer.string(deserializer),
            objectType: try Deserializer.string(deserializer),
            objectId: try Deserializer.string(deserializer),
            version: try Deserializer.string(deserializer),
            digest: try Deserializer.string(deserializer)
        )
    }
}

public struct SharedObjectSuiCallArg: Codable, KeyProtocol {
    public let type: String
    public let objectType: String
    public let objectId: objectId
    public let initialSharedVersion: SequenceNumber
    public let mutable: Bool
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, type)
        try Serializer.str(serializer, objectType)
        try Serializer.str(serializer, objectId)
        try Serializer.str(serializer, initialSharedVersion)
        try Serializer.bool(serializer, mutable)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SharedObjectSuiCallArg {
        return SharedObjectSuiCallArg(
            type: try Deserializer.string(deserializer),
            objectType: try Deserializer.string(deserializer),
            objectId: try Deserializer.string(deserializer),
            initialSharedVersion: try Deserializer.string(deserializer),
            mutable: try deserializer.bool()
        )
    }
}

public struct ProgrammableTransaction: Codable, KeyProtocol {
    public let transactions: [SuiTransaction]
    public let inputs: [SuiCallArg]
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(transactions, Serializer._struct)
        try serializer.sequence(inputs, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ProgrammableTransaction {
        return ProgrammableTransaction(
            transactions: try deserializer.sequence(valueDecoder: Deserializer._struct),
            inputs: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}

public enum TransactionKindName: String, KeyProtocol {
    case changeEpoch = "ChangeEpoch"
    case consensusCommitPrologue = "ConsensusCommitPrologue"
    case genesis = "Genesis"
    case programmableTransaction = "ProgrammableTransaction"
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.rawValue)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionKindName {
        let result = TransactionKindName(rawValue: try Deserializer.string(deserializer))
        if let result { return result }
        throw SuiError.notImplemented
    }
}

public enum SuiTransactionBlockKind: KeyProtocol {
    case changeEpoch(SuiChangeEpoch)
    case consensusCommitPrologue(SuiConsensusCommitPrologue)
    case genesis(Genesis)
    case programmableTransaction(ProgrammableTransaction)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .changeEpoch(let suiChangeEpoch):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: suiChangeEpoch)
        case .consensusCommitPrologue(let suiConsensusCommitPrologue):
            try Serializer.u8(serializer, 1)
            try Serializer._struct(serializer, value: suiConsensusCommitPrologue)
        case .genesis(let genesis):
            try Serializer.u8(serializer, 2)
            try Serializer._struct(serializer, value: genesis)
        case .programmableTransaction(let programmableTransaction):
            try Serializer.u8(serializer, 3)
            try Serializer._struct(serializer, value: programmableTransaction)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransactionBlockKind {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return SuiTransactionBlockKind.changeEpoch(try Deserializer._struct(deserializer))
        case 1:
            return SuiTransactionBlockKind.consensusCommitPrologue(try Deserializer._struct(deserializer))
        case 2:
            return SuiTransactionBlockKind.genesis(try Deserializer._struct(deserializer))
        case 3:
            return SuiTransactionBlockKind.programmableTransaction(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }
}

public enum TransactionData: KeyProtocol {
    case V1(TransactionDataV1)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .V1(let transactionDataV1):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: transactionDataV1)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionData {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionData.V1(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct TransactionDataV1: KeyProtocol {
    public let kind: SuiTransactionBlockKind
    public let sender: SuiAddress
    public let gasData: SuiGasData
    public let expiration: TransactionExpiration
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: kind)
        try Serializer.str(serializer, sender)
        try Serializer._struct(serializer, value: gasData)
        try Serializer._struct(serializer, value: expiration)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionDataV1 {
        return TransactionDataV1(
            kind: try Deserializer._struct(deserializer),
            sender: try Deserializer.string(deserializer),
            gasData: try Deserializer._struct(deserializer),
            expiration: try Deserializer._struct(deserializer)
        )
    }
}

extension SuiTransactionBlockKind {
    var kind: TransactionKindName {
        switch self {
        case .changeEpoch:
            return TransactionKindName.changeEpoch
        case .consensusCommitPrologue:
            return TransactionKindName.consensusCommitPrologue
        case .genesis:
            return TransactionKindName.genesis
        case .programmableTransaction:
            return TransactionKindName.programmableTransaction
        }
    }
}

public struct SuiTransactionBlockData: KeyProtocol {
    public let messageVersion: String
    public let transaction: SuiTransactionBlockKind
    public let sender: SuiAddress
    public let gasData: SuiGasData
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, messageVersion)
        try Serializer._struct(serializer, value: transaction)
        try Serializer.str(serializer, sender)
        try Serializer._struct(serializer, value: gasData)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransactionBlockData {
        return SuiTransactionBlockData(
            messageVersion: try Deserializer.string(deserializer),
            transaction: try Deserializer._struct(deserializer),
            sender: try Deserializer.string(deserializer),
            gasData: try Deserializer._struct(deserializer)
        )
    }
}

public enum GenericAuthoritySignature: KeyProtocol {
    case authoritySignature(AuthoritySignature)
    case authoritySignatureArray([AuthoritySignature])
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .authoritySignature(let authoritySignature):
            try Serializer.u8(serializer, 0)
            try Serializer.str(serializer, authoritySignature)
        case .authoritySignatureArray(let array):
            try Serializer.u8(serializer, 1)
            try serializer.sequence(array, Serializer.str)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> GenericAuthoritySignature {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return GenericAuthoritySignature.authoritySignature(
                try Deserializer.string(deserializer)
            )
        case 1:
            return GenericAuthoritySignature.authoritySignatureArray(
                try deserializer.sequence(valueDecoder: Deserializer.string)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct AuthorityQuorumSignInfo: KeyProtocol {
    public let epoch: EpochId
    public let signature: GenericAuthoritySignature
    public let signersMap: [UInt8]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, epoch)
        try Serializer._struct(serializer, value: signature)
        try serializer.sequence(signersMap, Serializer.u8)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> AuthorityQuorumSignInfo {
        return AuthorityQuorumSignInfo(
            epoch: try Deserializer.string(deserializer),
            signature: try Deserializer._struct(deserializer),
            signersMap: try deserializer.sequence(valueDecoder: Deserializer.u8)
        )
    }
}

public enum ExecutionStatusType: String {
    case success
    case failure
}

public struct ExecutionStatus {
    public let status: ExecutionStatusType
    public let error: String?
}

public struct TransactionEffectsModifiedAtVersions {
    public let objectId: objectId
    public let sequenceNumber: SequenceNumber
}

public struct OwnedObjectRef {
    public let owner: ObjectOwner
    public let reference: SuiObjectRef
}

public enum MessageVersion: String {
    case v1
}

public struct TransactionEffects {
    public var messageVersion: MessageVersion
    public var status: ExecutionStatus
    public var executedEpoch: EpochId
    public var modifiedAtVersions: [TransactionEffectsModifiedAtVersions]?
    public var gasUsed: GasCostSummary
    public var sharedObjects: [SuiObjectRef]?
    public var transactionDigest: TransactionDigest
    public var created: [OwnedObjectRef]?
    public var mutated: [OwnedObjectRef]?
    public var unwrapped: [OwnedObjectRef]?
    public var deleted: [SuiObjectRef]?
    public var unwrappedThenDeleted: [SuiObjectRef]?
    public var wrapped: [SuiObjectRef]?
    public var gasObject: OwnedObjectRef
    public var eventsDigest: TransactionEventDigest?
    public var dependencies: [TransactionDigest]?
}

public struct ExecutionResultType {
    public let mutableReferenceOutputs: [MutableReferenceOutputType]?
    public let returnValues: [ReturnValueType]?
}

public struct DevInspectResults {
    public let effects: TransactionEffects
    public let events: TransactionEvents
    public let results: [ExecutionResultType]?
    public let error: String?
}

public enum SuiTransactionBlockResponseQuery {
    case filter(TransactionFilter?)
    case options(SuiTransactionBlockResponseOptions?)
}

public enum TransactionFilter {
    case checkpoint(String)
    case fromAndToAddress(from: String, to: String)
    case transactionKind(String)
    case moveFunction(TransactionFilterMovefunction)
    case inputObject(objectId)
    case changedObject(objectId)
    case fromAddress(SuiAddress)
    case toAddress(SuiAddress)
}

public struct TransactionFilterMovefunction {
    public let package: objectId
    public let module: String?
    public let function: String?
}

public struct SuiTransactionBlock {
    public let data: SuiTransactionBlockData
    public let txSignature: [String]
}

public struct SuiObjectChangePublished {
    public let type: String = "published"
    public let packageId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest
    public let modules: [String]
}

public struct SuiObjectChangeTransferred {
    public let type: String = "transferred"
    public let sender: SuiAddress
    public let recipient: ObjectOwner
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest
}

public struct SuiObjectChangeMutated {
    public let type: String = "mutated"
    public let sender: SuiAddress
    public let owner: ObjectOwner
    public let objectType: String
    public let version: SequenceNumber
    public let previousVersion: SequenceNumber
    public let digest: ObjectDigest
}

public struct SuiObjectChangeDeleted {
    public let type: String = "deleted"
    public let sender: SuiAddress
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
}

public struct SuiObjectChangeWrapped {
    public let type: String = "wrapped"
    public let sender: SuiAddress
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
}

public struct SuiObjectChangeCreated {
    public let type: String = "created"
    public let sender: SuiAddress
    public let owner: ObjectOwner
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest
}

public enum SuiObjectChange {
    case published(SuiObjectChangePublished)
    case transferred(SuiObjectChangeTransferred)
    case mutated(SuiObjectChangeMutated)
    case deleted(SuiObjectChangeDeleted)
    case wrapped(SuiObjectChangeWrapped)
    case created(SuiObjectChangeCreated)
    
    var kind: String {
        switch self {
        case .published:
            return "published"
        case .transferred:
            return "transferred"
        case .mutated:
            return "mutated"
        case .deleted:
            return "deleted"
        case .wrapped:
            return "wrapped"
        case .created:
            return "created"
        }
    }
}

public struct BalanceChange {
    public let owner: ObjectOwner
    public let coinType: String
    public let amount: String
}

public struct SuiTransactionBlockResponse {
    public let digest: TransactionDigest
    public let transaction: SuiTransactionBlock?
    public let effects: TransactionEffects?
    public let events: TransactionEvents?
    public let timestampMs: String?
    public let checkpoint: String?
    public let confirmedLocalExecution: Bool?
    public let objectChanges: [SuiObjectChange]?
    public let balanceChanges: [BalanceChange]?
    public let errors: [String]?
}

public struct SuiTransactionBlockResponseOptions {
    public let showInput: Bool?
    public let showEffects: Bool?
    public let showEvents: Bool?
    public let showObjectChanges: Bool?
    public let showBalanceChanges: Bool?
}

public struct PaginatedTransactionResponse {
    public let data: [SuiTransactionBlockResponse]
    public let nextCursor: TransactionDigest?
    public let hasNextPage: Bool
}

public struct DryRunTransactionBlockResponse {
    public let digest: String
    public let transaction: SuiTransactionBlockData
    public let txSigntures: [String]
    public let rawTransaction: String
    public let effects: TransactionEffects
    public let objectChanges: [SuiObjectChange]
}

public struct TransactionFunctions {
    // MARK: Helper Functions
    public static func getTransaction(_ tx: SuiTransactionBlockResponse) -> SuiTransactionBlock? {
        return tx.transaction
    }
    
    public static func getTransactionDigest(_ tx: SuiTransactionBlockResponse) -> TransactionDigest {
        return tx.digest
    }
    
    public static func getTransactionSignature(_ tx: SuiTransactionBlockResponse) -> [String]? {
        return tx.transaction?.txSignature
    }
    
    // MARK: TransactionData
    public static func getTransactionSender(_ tx: SuiTransactionBlockResponse) -> SuiAddress? {
        return tx.transaction?.data.sender
    }
    
    public static func getGasData(_ tx: SuiTransactionBlockResponse) -> SuiGasData? {
        return tx.transaction?.data.gasData
    }
    
    public static func getTransactionGasObject(_ tx: SuiTransactionBlockResponse) -> [SuiObjectRef]? {
        return TransactionFunctions.getGasData(tx)?.payment
    }
    
    public static func getTransactionGasPrice(_ tx: SuiTransactionBlockResponse) -> String? {
        return TransactionFunctions.getGasData(tx)?.price
    }
    
    public static func getTransactionGasBudget(_ tx: SuiTransactionBlockResponse) -> String? {
        return TransactionFunctions.getGasData(tx)?.budget
    }
    
    public static func getChangeEpochTransaction(_ data: SuiTransactionBlockKind) -> SuiChangeEpoch? {
        switch data {
        case .changeEpoch(let changeEpoch):
            return changeEpoch
        default:
            return nil
        }
    }
    
    public static func getConsensusCommitPrologueTransaction(_ data: SuiTransactionBlockKind) -> SuiConsensusCommitPrologue? {
        switch data {
        case .consensusCommitPrologue(let suiConsensusCommitPrologue):
            return suiConsensusCommitPrologue
        default:
            return nil
        }
    }
    
    public static func getTransactionKind(_ data: SuiTransactionBlockResponse) -> SuiTransactionBlockKind? {
        return data.transaction?.data.transaction
    }
    
    public static func getTransactionKindName(_ data: SuiTransactionBlockKind) -> TransactionKindName {
        return data.kind
    }
    
    public static func getProgrammableTransaction(_ data: SuiTransactionBlockKind) -> ProgrammableTransaction? {
        switch data {
        case .programmableTransaction(let suiProgrammableTransaction):
            return suiProgrammableTransaction
        default:
            return nil
        }
    }
    
    // MARK: ExecutationStatus
    public static func getExecutionStatusType(_ data: SuiTransactionBlockResponse) -> ExecutionStatusType? {
        return getExecutionStatus(data)?.status
    }
    
    public static func getExecutionStatus(_ data: SuiTransactionBlockResponse) -> ExecutionStatus? {
        return getTransactionEffects(data)?.status
    }
    
    public static func getExecutionStatusError(_ data: SuiTransactionBlockResponse) -> String? {
        return getExecutionStatus(data)?.error
    }
    
    public static func getExecutionStatusGasSummary(_ data: SuiTransactionBlockResponse) -> GasCostSummary? {
        return getTransactionEffects(data)?.gasUsed
    }
    
    public static func getExecutionStatusGasSummary(_ data: TransactionEffects) -> GasCostSummary? {
        return data.gasUsed
    }
    
    public static func getTotalGasUsed(_ data: SuiTransactionBlockResponse) -> BigInt? {
        let gasSummary = getExecutionStatusGasSummary(data)
        
        if let gasSummary {
            if
                let computationCost = BigInt(gasSummary.computationCost),
                let storageCost = BigInt(gasSummary.storageCost),
                let storageRebate = BigInt(gasSummary.storageRebate)
            {
                return computationCost + storageCost - storageRebate
            }
        }
        
        return nil
    }
    
    public static func getTotalGasUsed(_ data: TransactionEffects) -> BigInt? {
        let gasSummary = getExecutionStatusGasSummary(data)
        
        if let gasSummary {
            if
                let computationCost = BigInt(gasSummary.computationCost),
                let storageCost = BigInt(gasSummary.storageCost),
                let storageRebate = BigInt(gasSummary.storageRebate)
            {
                return computationCost + storageCost - storageRebate
            }
        }
        
        return nil
    }
    
    public static func getTotalGasUsedUpperBound(_ data: SuiTransactionBlockResponse) -> BigInt? {
        let gasSummary = getExecutionStatusGasSummary(data)
        
        if let gasSummary {
            if
                let computationCost = BigInt(gasSummary.computationCost),
                let storageCost = BigInt(gasSummary.storageCost)
            {
                return computationCost + storageCost
            }
        }
        
        return nil
    }
    
    public static func getTotalGasUsedUpperBound(_ data: TransactionEffects) -> BigInt? {
        let gasSummary = getExecutionStatusGasSummary(data)
        
        if let gasSummary {
            if
                let computationCost = BigInt(gasSummary.computationCost),
                let storageCost = BigInt(gasSummary.storageCost)
            {
                return computationCost + storageCost
            }
        }
        
        return nil
    }
    
    public static func getTransactionEffects(_ data: SuiTransactionBlockResponse) -> TransactionEffects? {
        return data.effects
    }
    
    // MARK: Transaction Effects
    public static func getEvents(_ data: SuiTransactionBlockResponse) -> [SuiEvent]? {
        return data.events
    }
    
    public static func getCreatedObjects(_ data: SuiTransactionBlockResponse) -> [OwnedObjectRef]? {
        return getTransactionEffects(data)?.created
    }
    
    // MARK: TransactionResponse
    public static func getTimestampFromTransactionResponse(_ data: SuiTransactionBlockResponse) -> String? {
        return data.timestampMs
    }
    
    public static func getNewlyCreatedCoinRefsAfterSplit(_ data: SuiTransactionBlockResponse) -> [SuiObjectRef]? {
        return getTransactionEffects(data)?.created?.map { $0.reference }
    }
    
    public static func getObjectChanges(_ data: SuiTransactionBlockResponse) -> [SuiObjectChange]? {
        return data.objectChanges
    }
    
    public static func getPublishedObjectChanges(_ data: SuiTransactionBlockResponse) -> [SuiObjectChangePublished] {
        let publishedChanges = data.objectChanges?.compactMap { change -> SuiObjectChangePublished? in
            switch change {
            case .published(let publishedChange):
                return publishedChange
            default:
                return nil
            }
        }
        return publishedChanges ?? []
    }
}
