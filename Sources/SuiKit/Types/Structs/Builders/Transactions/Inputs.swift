//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import AnyCodable

public struct Inputs {
    public func pure(data: Data) -> PureCallArg {
        return PureCallArg(pure: [UInt8](data))
    }
    
    public func pure(data: TypeTag) throws -> PureCallArg {
        let ser = Serializer()
        try data.serialize(ser)
        return PureCallArg(pure: [UInt8](ser.output()))
    }
    
    public func objectRef(suiObjectRef: SuiObjectRef) -> ObjectCallArg {
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
    
    public func sharedObjectRef(sharedObjectRef: SharedObjectRef) -> ObjectCallArg {
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

public enum ObjectArg: Codable {
    case immOrOwned(ImmOrOwned)
    case shared(SharedArg)
}

public struct ObjectCallArg {
    public let object: ObjectArg
}

public struct BuilderCallArg {
    public let pureCallArg: PureCallArg
    public let objectCallArg: ObjectCallArg
}

public let MAX_PURE_ARGUMENT_SIZE = 16 * 1024

public struct ImmOrOwned: Codable {
    public let immOrOwned: SuiObjectRef
}

public struct SharedArg: Codable {
    public let shared: SharedObjectArg
}

public struct SharedObjectArg: Codable {
    public let objectId: String
    public let initialSharedVersion: UInt8
    public let mutable: Bool
}

public struct PureCallArg: Codable {
    public let pure: [UInt8]
}

public let SUI_ADDRESS_LENGTH = 32

public func normalizeSuiAddress(value: String, forceAdd0x: Bool = false) -> SuiAddress {
    var address = value.lowercased()
    if !forceAdd0x && address.hasPrefix("0x") {
        address = String(address.dropFirst(2))
    }
    return "0x" + address.padding(toLength: SUI_ADDRESS_LENGTH * 2, withPad: "0", startingAt: 0)
}
