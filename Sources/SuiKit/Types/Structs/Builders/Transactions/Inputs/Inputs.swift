//
//  Inputs.swift
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

public struct Inputs {
    /// Creates a `PureCallArg` object from the provided `Data`.
    ///
    /// - Parameter data: The `Data` instance used to initialize the `PureCallArg` object.
    /// - Returns: A `PureCallArg` object initialized with the provided data.
    public static func pure(data: Data) -> PureCallArg {
        return PureCallArg(value: data)
    }

    /// Creates a `PureCallArg` object from the provided `SuiJsonValue`.
    ///
    /// - Parameter json: The `SuiJsonValue` used to initialize the `PureCallArg` object.
    /// - Throws: If unable to serialize the provided `json` value.
    /// - Returns: A `PureCallArg` object initialized with the serialized output of the provided JSON value.
    public static func pure(json: SuiJsonValue) throws -> PureCallArg {
        let ser = Serializer()
        try Serializer._struct(ser, value: json)
        return PureCallArg(value: ser.output())
    }

    /// Creates an `ObjectArg` of type `.immOrOwned` from the provided `SuiObjectRef`.
    ///
    /// - Parameter suiObjectRef: The `SuiObjectRef` used to initialize the `ObjectArg`.
    /// - Throws: If unable to normalize the SUI address contained in `suiObjectRef`.
    /// - Returns: An `ObjectArg` object initialized with the `.immOrOwned` variant.
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

    /// Creates an `ObjectArg` of type `.shared` from the provided `SharedObjectRef`.
    ///
    /// - Parameter sharedObjectRef: The `SharedObjectRef` used to initialize the `ObjectArg`.
    /// - Throws: If unable to normalize the SUI address contained in `sharedObjectRef`.
    /// - Returns: An `ObjectArg` object initialized with the `.shared` variant.
    public static func sharedObjectRef(sharedObjectRef: SharedObjectRef) throws -> ObjectArg {
        let sharedArg = try SharedObjectArg(
            objectId: normalizeSuiAddress(value: sharedObjectRef.objectId),
            initialSharedVersion: sharedObjectRef.initialSharedVersion,
            mutable: sharedObjectRef.mutable
        )
        return .shared(sharedArg)
    }

    /// Overload that creates an `ObjectArg` of type `.shared` from the provided `SharedObjectArg`.
    ///
    /// - Parameter sharedObjectArg: The `SharedObjectArg` used to initialize the `ObjectArg`.
    /// - Returns: An `ObjectArg` object initialized with the `.shared` variant.
    public static func sharedObjectRef(sharedObjectArg: SharedObjectArg) -> ObjectArg {
        return .shared(sharedObjectArg)
    }

    /// Normalizes the SUI address from the provided `objectId`.
    ///
    /// - Parameter arg: The `objectId` to be normalized.
    /// - Throws: If unable to normalize the provided `objectId`.
    /// - Returns: A normalized SUI address as a string.
    public static func getIdFromCallArg(arg: ObjectId) throws -> String {
        return try normalizeSuiAddress(value: arg)
    }

    public static func getIdFromCallArg(arg: ObjectCallArg) throws -> String {
        if case .immOrOwned(let immOrOwned) = arg.object {
            return try normalizeSuiAddress(value: immOrOwned.ref.objectId)
        }

        if case .shared(let shared) = arg.object {
            return try normalizeSuiAddress(value: shared.objectId)
        }

        throw SuiError.notImplemented
    }

    /// Normalizes the SUI address from the provided `ObjectArg`.
    ///
    /// - Parameter arg: The `ObjectArg` instance containing the address to be normalized.
    /// - Throws: If unable to normalize the address contained in `arg`.
    /// - Returns: A normalized SUI address as a string.
    public static func getIdFromCallArg(arg: ObjectArg) throws -> String {
        switch arg {
        case .immOrOwned(let immOwned):
            return try normalizeSuiAddress(value: immOwned.ref.objectId)
        case .shared(let shared):
            return try normalizeSuiAddress(value: shared.objectId)
        }
    }

    public static func getIdFromCallArg(value: TransactionObjectInput) throws -> String {
        if case .objectCallArg(let objCallArg) = value {
            return try Self.getIdFromCallArg(arg: objCallArg)
        }
        if case .string(let string) = value {
            return try Self.normalizeSuiAddress(value: string)
        }
        throw SuiError.notImplemented
    }

    /// The constant value defining the length of a SUI address.
    public static let suiAddressLength = 32

    /// The constant value defining the maximum length of a pure argument.
    public static let maxPureArgumentLength = 16 * 1024

    /// Normalizes a SUI address value.
    ///
    /// - Parameters:
    ///   - value: The string value to be normalized.
    ///   - forceAdd0x: If `true`, forcibly adds "0x" prefix to the address, if not already present.
    /// - Throws: `SuiError.addressTooLong` if the input address is too long.
    /// - Returns: A string representing the normalized SUI address.
    public static func normalizeSuiAddress(value: String, forceAdd0x: Bool = false) throws -> String {
        var address = value.lowercased()
        if !forceAdd0x && address.hasPrefix("0x") {
            address = String(address.dropFirst(2))
        }
        guard address.count <= (Self.suiAddressLength * 2) else { throw SuiError.customError(message: "Address too long (max \(Self.suiAddressLength * 2) characters)") }
        return "0x" + String().padding(toLength: ((Self.suiAddressLength * 2) - address.count), withPad: "0", startingAt: 0) + address
    }
}
