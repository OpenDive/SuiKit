//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import AnyCodable

public struct Inputs {
    public static func pure(data: Data) -> PureCallArg {
        return PureCallArg(pure: [UInt8](data))
    }
    
    public static func objectRef(suiObjectRef: SuiObjectRef) -> ObjectCallArg {
        return ObjectCallArg(
            object: .immOrOwned(
                ImmOrOwned(
                    immOrOwned: SuiObjectRef(
                        version: suiObjectRef.version,
                        objectId: normalizeSuiAddress(value: suiObjectRef.objectId),
                        digest: suiObjectRef.digest)
                )
            )
        )
    }
    
    public static func sharedObjectRef(sharedObjectRef: SharedObjectRef) -> ObjectCallArg {
        return ObjectCallArg(
            object: .shared(
                SharedArg(
                    shared: SharedObjectArg(
                        objectId: normalizeSuiAddress(value: sharedObjectRef.objectId),
                        initialSharedVersion: sharedObjectRef.initialSharedVersion,
                        mutable: sharedObjectRef.mutable
                    )
                )
            )
        )
    }
}

public enum ObjectArg: Codable, KeyProtocol {
    case immOrOwned(ImmOrOwned)
    case shared(SharedArg)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .immOrOwned(let immOrOwned):
            try Serializer.u8(serializer, UInt8(0))
            try Serializer._struct(serializer, value: immOrOwned)
        case .shared(let sharedArg):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: sharedArg)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ObjectArg {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return ObjectArg.immOrOwned(
                try Deserializer._struct(deserializer)
            )
        case 1:
            return ObjectArg.shared(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct ObjectCallArg {
    public let object: ObjectArg
}

public struct BuilderCallArg {
    public let pureCallArg: PureCallArg
    public let objectCallArg: ObjectCallArg
}

public let MAX_PURE_ARGUMENT_SIZE = 16 * 1024

public struct ImmOrOwned: Codable, KeyProtocol {
    public let immOrOwned: SuiObjectRef
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: immOrOwned)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ImmOrOwned {
        return ImmOrOwned(
            immOrOwned: try Deserializer._struct(deserializer)
        )
    }
}

public struct SharedArg: Codable, KeyProtocol {
    public let shared: SharedObjectArg
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: shared)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SharedArg {
        return SharedArg(
            shared: try Deserializer._struct(deserializer)
        )
    }
}

public func getIdFromCallArg(arg: objectId) -> String {
    return normalizeSuiAddress(value: arg)
}

public func getIdFromCallArg(arg: ObjectCallArg) -> String {
    switch arg.object {
    case .immOrOwned(let immOwned):
        return normalizeSuiAddress(value: immOwned.immOrOwned.objectId)
    case .shared(let shared):
        return normalizeSuiAddress(value: shared.shared.objectId)
    }
}

public struct SharedObjectArg: Codable, KeyProtocol {
    public let objectId: objectId
    public let initialSharedVersion: UInt8
    public let mutable: Bool
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, objectId)
        try Serializer.u8(serializer, initialSharedVersion)
        try Serializer.bool(serializer, mutable)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SharedObjectArg {
        return SharedObjectArg(
            objectId: try Deserializer.string(deserializer),
            initialSharedVersion: try Deserializer.u8(deserializer),
            mutable: try deserializer.bool()
        )
    }
}

public struct PureCallArg: Codable, KeyProtocol {
    public let pure: [UInt8]
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(pure, Serializer.u8)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PureCallArg {
        return PureCallArg(pure:
            try deserializer.sequence(valueDecoder: Deserializer.u8)
        )
    }
}

public let SUI_ADDRESS_LENGTH = 32

public func normalizeSuiAddress(value: String, forceAdd0x: Bool = false) -> SuiAddress {
    var address = value.lowercased()
    if !forceAdd0x && address.hasPrefix("0x") {
        address = String(address.dropFirst(2))
    }
    return "0x" + address.padding(toLength: SUI_ADDRESS_LENGTH * 2, withPad: "0", startingAt: 0)
}
