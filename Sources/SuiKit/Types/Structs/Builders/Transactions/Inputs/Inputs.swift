//
//  Inputs.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

public struct Inputs {
    public static func pure(data: Data) -> PureCallArg {
        return PureCallArg(value: data)
    }

    public static func pure(json: SuiJsonValue) throws -> PureCallArg {
        let ser = Serializer()
        try Serializer._struct(ser, value: json)
        return PureCallArg(value: ser.output())
    }

    public static func immOrOwnedRef(suiObjectRef: SuiObjectRef) throws -> ObjectArg {
        let immOrOwned = ImmOrOwned(
            ref: SuiObjectRef(
                objectId: try normalizeSuiAddress(value: suiObjectRef.objectId),
                version: suiObjectRef.version,
                digest: suiObjectRef.digest
            )
        )
        return .immOrOwned(immOrOwned)
    }

    public static func sharedObjectRef(sharedObjectRef: SharedObjectRef) throws -> ObjectArg {
        let sharedArg = try SharedObjectArg(
            objectId: normalizeSuiAddress(value: sharedObjectRef.objectId),
            initialSharedVersion: sharedObjectRef.initialSharedVersion,
            mutable: sharedObjectRef.mutable
        )
        return .shared(sharedArg)
    }

    public static func sharedObjectRef(sharedObjectArg: SharedObjectArg) -> ObjectArg {
        return .shared(sharedObjectArg)
    }

    public static func getIdFromCallArg(arg: objectId) throws -> String {
        return try normalizeSuiAddress(value: arg)
    }

    public static func getIdFromCallArg(arg: ObjectArg) throws -> String {
        switch arg {
        case .immOrOwned(let immOwned):
            return try normalizeSuiAddress(value: immOwned.ref.objectId)
        case .shared(let shared):
            return try normalizeSuiAddress(value: shared.objectId)
        }
    }

    public static let suiAddressLength = 32

    public static let maxPureArgumentLength = 16 * 1024

    public static func normalizeSuiAddress(value: String, forceAdd0x: Bool = false) throws -> String {
        var address = value.lowercased()
        if !forceAdd0x && address.hasPrefix("0x") {
            address = String(address.dropFirst(2))
        }
        return "0x" + String().padding(toLength: ((Self.suiAddressLength * 2) - address.count), withPad: "0", startingAt: 0) + address
    }
}
