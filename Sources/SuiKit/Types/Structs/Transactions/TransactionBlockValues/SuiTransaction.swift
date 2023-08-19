//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum SuiTransactionKind: String {
    case moveCall = "MoveCall"
    case transferObjects = "TransferObjects"
    case splitCoins = "SplitCoins"
    case mergeCoins = "MergeCoins"
    case publish = "Publish"
    case makeMoveVec = "MakeMoveVec"
    case upgrade = "Upgrade"
}

public enum SuiTransaction: KeyProtocol {
    case moveCall(MoveCallTransaction)
    case transferObjects(TransferObjectsTransaction)
    case splitCoins(SplitCoinsTransaction)
    case mergeCoins(MergeCoinsTransaction)
    case publish(PublishTransaction)
    case makeMoveVec(MakeMoveVecTransaction)
    case upgrade(UpgradeTransaction)

    public func kind() -> SuiTransactionKind {
        switch self {
        case .moveCall:
            return .moveCall
        case .transferObjects:
            return .transferObjects
        case .splitCoins:
            return .splitCoins
        case .mergeCoins:
            return .mergeCoins
        case .publish:
            return .publish
        case .makeMoveVec:
            return .makeMoveVec
        case .upgrade:
            return .upgrade
        }
    }

    public func transaction() -> any TransactionProtocol {
        switch self {
        case .moveCall(let moveCallTransaction):
            return moveCallTransaction
        case .transferObjects(let transferObjectsTransaction):
            return transferObjectsTransaction
        case .splitCoins(let splitCoinsTransaction):
            return splitCoinsTransaction
        case .mergeCoins(let mergeCoinsTransaction):
            return mergeCoinsTransaction
        case .publish(let publishTransaction):
            return publishTransaction
        case .makeMoveVec(let makeMoveVecTransaction):
            return makeMoveVecTransaction
        case .upgrade(let upgradeTransaction):
            return upgradeTransaction
        }
    }

    public static func fromJSON(_ input: JSON) -> SuiTransaction? {
        if input["MoveCall"].exists() {
            guard let moveCall = MoveCallTransaction(input: input["MoveCall"]) else { return nil }
            return .moveCall(moveCall)
        }
        if input["TransferObjects"].exists() {
            guard let transfer = TransferObjectsTransaction(input: input["TransferObjects"]) else { return nil }
            return .transferObjects(transfer)
        }
        if input["SplitCoins"].exists() {
            guard let split = SplitCoinsTransaction(input: input["SplitCoins"]) else { return nil }
            return .splitCoins(split)
        }
        if input["MergeCoins"].exists() {
            guard let merge = MergeCoinsTransaction(input: input["MergeCoins"]) else { return nil }
            return .mergeCoins(merge)
        }
        if input["Publish"].exists() {
            guard let publish = PublishTransaction(input: input["Publish"]) else { return nil }
            return .publish(publish)
        }
        if input["MakeMoveVec"].exists() {
            guard let vec = MakeMoveVecTransaction(input: input["MakeMoveVec"]) else { return nil }
            return .makeMoveVec(vec)
        }
        if input["Upgrade"].exists() {
            guard let upgrade = UpgradeTransaction(input: input["Upgrade"]) else { return nil }
            return .upgrade(upgrade)
        }
        return nil
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .moveCall(let moveCall):
            try Serializer.u8(serializer, UInt8(0))
            try Serializer._struct(serializer, value: moveCall)
        case .transferObjects(let transferObjects):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: transferObjects)
        case .splitCoins(let splitCoins):
            try Serializer.u8(serializer, UInt8(2))
            try Serializer._struct(serializer, value: splitCoins)
        case .mergeCoins(let mergeCoins):
            try Serializer.u8(serializer, UInt8(3))
            try Serializer._struct(serializer, value: mergeCoins)
        case .publish(let publish):
            try Serializer.u8(serializer, UInt8(4))
            try Serializer._struct(serializer, value: publish)
        case .makeMoveVec(let makeMoveVec):
            try Serializer.u8(serializer, UInt8(5))
            try Serializer._struct(serializer, value: makeMoveVec)
        case .upgrade(let upgrade):
            try Serializer.u8(serializer, UInt8(6))
            try Serializer._struct(serializer, value: upgrade)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransaction {
        let result = try Deserializer.u8(deserializer)
        switch result {
        case 0:
            return .moveCall(try Deserializer._struct(deserializer))
        case 1:
            return .transferObjects(try Deserializer._struct(deserializer))
        case 2:
            return .splitCoins(try Deserializer._struct(deserializer))
        case 3:
            return .mergeCoins(try Deserializer._struct(deserializer))
        case 4:
            return .publish(try Deserializer._struct(deserializer))
        case 5:
            return .makeMoveVec(try Deserializer._struct(deserializer))
        case 6:
            return .upgrade(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }
}
