//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import AnyCodable

public protocol InputProtocol: KeyProtocol {
    var type: InputType { get }
}

public extension InputProtocol {
    func isMutableSharedObjectInput() -> Bool {
        return self.getSharedObjectInput()?.mutable ?? false
    }

    func getSharedObjectInput() -> SharedObjectArg? {
        switch self.type {
        case .sharedObject(let sharedObject):
            return sharedObject
        default:
            return nil
        }
    }
}

public indirect enum InputType {
    case pure([UInt8])
    case immOrOwned(ImmOrOwned)
    case sharedObject(SharedObjectArg)
}

public struct Inputs {
    public static func pure(data: Data) -> PureCallArg {
        return PureCallArg(pure: [UInt8](data))
    }
    
    public static func objectRef(suiObjectRef: SuiObjectRef) throws -> ObjectCallArg {
        let immOrOwned = ImmOrOwned(
            immOrOwned: SuiObjectRef(
                objectId: normalizeSuiAddress(value: suiObjectRef.objectId),
                version: suiObjectRef.version,
                digest: suiObjectRef.digest
            )
        )
        return ObjectCallArg(
            object: .immOrOwned(immOrOwned),
            type: .immOrOwned(immOrOwned)
        )
    }
    
    public static func sharedObjectRef(sharedObjectRef: SharedObjectRef) throws -> ObjectCallArg {
        let sharedArg = SharedArg(
            shared: try SharedObjectArg(
                objectId: normalizeSuiAddress(value: sharedObjectRef.objectId),
                initialSharedVersion: sharedObjectRef.initialSharedVersion,
                mutable: sharedObjectRef.mutable
            )
        )
        return ObjectCallArg(
            object: .shared(sharedArg),
            type: .sharedObject(sharedArg.shared)
        )
    }
}

public enum ObjectArg: KeyProtocol {
    case immOrOwned(ImmOrOwned)
    case shared(SharedArg)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .immOrOwned(let immOrOwned):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: immOrOwned)
        case .shared(let sharedArg):
            try Serializer.u8(serializer, UInt8(2))
            try Serializer._struct(serializer, value: sharedArg)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ObjectArg {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return ObjectArg.shared(
                try Deserializer._struct(deserializer)
            )
        case 1:
            return ObjectArg.immOrOwned(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}

public struct ObjectCallArg: InputProtocol {
    public let object: ObjectArg
    public var type: InputType

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.object)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ObjectCallArg {
        try Deserializer._struct(deserializer)
    }
}

public struct BuilderCallArg {
    public let pureCallArg: PureCallArg
    public let objectCallArg: ObjectCallArg
}

public let MAX_PURE_ARGUMENT_SIZE = 16 * 1024

public struct ImmOrOwned: KeyProtocol {
    public let immOrOwned: SuiObjectRef
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(0)
        try Serializer._struct(serializer, value: immOrOwned)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ImmOrOwned {
        return ImmOrOwned(
            immOrOwned: try Deserializer._struct(deserializer)
        )
    }
}

public struct SharedArg: KeyProtocol {
    public let shared: SharedObjectArg
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(1)
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

public func getIdFromCallArg(arg: ObjectCallArg) throws -> String {
    switch arg.object {
    case .immOrOwned(let immOwned):
        return normalizeSuiAddress(value: immOwned.immOrOwned.objectId)
    case .shared(let shared):
        return normalizeSuiAddress(value: shared.shared.objectId)
    }
}

public struct SharedObjectArg: KeyProtocol {
    public let objectId: String
    public let initialSharedVersion: UInt8
    public let mutable: Bool

    public init(objectId: objectId, initialSharedVersion: UInt8, mutable: Bool) throws {
        self.objectId = objectId
        self.initialSharedVersion = initialSharedVersion
        self.mutable = mutable
    }
    
    public func serialize(_ serializer: Serializer) throws {
        let publicKey = try ED25519PublicKey(hexString: objectId)
        publicKey.serializeModule(serializer)
        try Serializer.u8(serializer, initialSharedVersion)
        try Serializer.bool(serializer, mutable)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SharedObjectArg {
        throw SuiError.notImplemented
    }
}

public struct PureCallArg: InputProtocol {
    public let pure: [UInt8]
    public var type: InputType

    public init(pure: [UInt8]) {
        self.pure = pure
        self.type = .pure(pure)
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(0))
        serializer.fixedBytes(Data(self.pure))
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PureCallArg {
        return PureCallArg(
            pure: try deserializer.sequence(valueDecoder: Deserializer.u8)
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
