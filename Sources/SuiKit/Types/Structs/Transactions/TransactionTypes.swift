//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import AnyCodable
import BigInt

public typealias EpochId = String
public typealias SequenceNumber = String
public typealias ObjectDigest = String
public typealias AuthoritySignature = String
public typealias TransactionEventDigest = String
public typealias ReturnValueType = ([UInt8], String)
public typealias TransactionEvents = [SuiEvent]
public typealias MutableReferenceOutputType = (SuiArgument, [UInt8], String)
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

public enum SuiArgument: Codable, KeyProtocol, EncodingProtocol {
    case gasCoin
    case input(Int)
    case result(Int)
    case nestedResult(Int, Int)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .gasCoin:
            try Serializer.u8(serializer, 0)
        case .input(let int):
            try Serializer.u8(serializer, 1)
            try Serializer.u64(serializer, UInt64(int))
        case .result(let int):
            try Serializer.u8(serializer, 2)
            try Serializer.u64(serializer, UInt64(int))
        case .nestedResult(let int, let int2):
            try Serializer.u8(serializer, 3)
            try Serializer.u64(serializer, UInt64(int))
            try Serializer.u64(serializer, UInt64(int2))
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiArgument {
        let result = try Deserializer.u8(deserializer)
        
        switch result {
        case 0:
            return SuiArgument.gasCoin
        case 1:
            return SuiArgument.input(Int(try Deserializer.u64(deserializer)))
        case 2:
            return SuiArgument.result(Int(try Deserializer.u64(deserializer)))
        case 3:
            return SuiArgument.nestedResult(
                Int(try Deserializer.u64(deserializer)),
                Int(try Deserializer.u64(deserializer))
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct MoveCallSuiTransaction: Codable, KeyProtocol {
    public let arguments: [SuiArgument]?
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
            arguments: try deserializer.sequence(valueDecoder: SuiArgument.deserialize),
            typeArguments: try deserializer.sequence(valueDecoder: Deserializer.string),
            package: try Deserializer.string(deserializer),
            module: try Deserializer.string(deserializer),
            function: try Deserializer.string(deserializer)
        )
    }
}

public enum SuiTransaction: Codable, KeyProtocol {
    case moveCall(MoveCallSuiTransaction)
    case transferObjects([SuiArgument], SuiArgument)
    case splitCoins(SuiArgument, [SuiArgument])
    case mergeCoins(SuiArgument, [SuiArgument])
    case publish(PublishType)
    case upgrade(UpgradeType)
    case makeMoveVec(String?, [SuiArgument])
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .moveCall(let moveCallSuiTransaction):
            try Serializer.u8(serializer, 0)
            try Serializer._struct(serializer, value: moveCallSuiTransaction)
        case .transferObjects(let array, let suiArgument):
            try Serializer.u8(serializer, 1)
            try serializer.sequence(array, Serializer._struct)
        case .splitCoins(let suiArgument, let array):
            try Serializer.u8(serializer, 2)
        case .mergeCoins(let suiArgument, let array):
            try Serializer.u8(serializer, 3)
        case .publish(let publishType):
            try Serializer.u8(serializer, 4)
        case .upgrade(let upgradeType):
            try Serializer.u8(serializer, 5)
        case .makeMoveVec(let string, let array):
            try Serializer.u8(serializer, 6)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransaction {
        <#code#>
    }
}

public enum PublishType: Codable {
    case oldType(SuiMovePackage, [objectId])
    case newType([objectId])
}

public enum UpgradeType: Codable {
    case oldType(SuiMovePackage, [objectId], objectId, SuiArgument)
    case newType([objectId], objectId, SuiArgument)
}

public enum SuiCallArg: Codable {
    case pure(PureSuiCallArg)
    case ownedObject(OwnedObjectSuiCallArg)
    case sharedObject(SharedObjectSuiCallArg)
}

public struct PureSuiCallArg: Codable {
    public let type: String
    public let valueType: String?
    public let value: SuiJsonValue
}

public enum SuiJsonValue: Codable {
    case boolean(Bool)
    case number(Double)
    case string(String)
    case callArg(CallArg)
    case array([SuiJsonValue])
}

public struct OwnedObjectSuiCallArg: Codable {
    public let type: String
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest
}

public struct SharedObjectSuiCallArg: Codable {
    public let type: String
    public let objectType: String
    public let objectId: objectId
    public let initialSharedVersion: SequenceNumber
    public let mutable: Bool
}

public struct ProgrammableTransaction: Codable {
    public let transactions: [SuiTransaction]
    public let inputs: [SuiCallArg]
}

public enum TransactionKindName: String {
    case changeEpoch = "ChangeEpoch"
    case consensusCommitPrologue = "ConsensusCommitPrologue"
    case genesis = "Genesis"
    case programmableTransaction = "ProgrammableTransaction"
}

public enum SuiTransactionBlockKind {
    case changeEpoch(SuiChangeEpoch)
    case consensusCommitPrologue(SuiConsensusCommitPrologue)
    case genesis(Genesis)
    case programmableTransaction(ProgrammableTransaction)
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

public struct SuiTransactionBlockData {
    public let messageVersion: String
    public let transaction: SuiTransactionBlockKind
    public let sender: SuiAddress
    public let gasData: SuiGasData
}

public enum GenericAuthoritySignature {
    case authoritySignature(AuthoritySignature)
    case authoritySignatureArray([AuthoritySignature])
}

public struct AuthorityQuorumSignInfo {
    public let epoch: EpochId
    public let signature: GenericAuthoritySignature
    public let signersMap: [UInt8]
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

public struct TransactionEffects {
    public enum MessageVersion: String {
        case v1
    }
    
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
    public let effects: TransactionEffects
    public let events: TransactionEvents
    public let objectChanges: [SuiObjectChange]
    public let balanceChanges: [BalanceChange]
    public let input: SuiTransactionBlockData
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
