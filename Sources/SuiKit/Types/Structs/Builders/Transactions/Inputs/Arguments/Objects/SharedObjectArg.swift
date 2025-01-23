//
//  SharedObjectArg.swift
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

/// A structure representing the argument for a Shared Object, conforming to `KeyProtocol`.
public struct SharedObjectArg: KeyProtocol {
    /// A string that uniquely identifies the object.
    public var objectId: String

    /// A `UInt64` value representing the initial shared version of the object.
    public var initialSharedVersion: UInt64

    /// A Boolean value indicating whether the object is mutable.
    public var mutable: Bool

    /// Initializes a new instance of `SharedObjectArg`.
    ///
    /// - Parameters:
    ///   - objectId: A string uniquely identifying the object.
    ///   - initialSharedVersion: A `UInt64` value representing the initial shared version.
    ///   - mutable: A Boolean value indicating whether the object is mutable.
    public init(objectId: String, initialSharedVersion: UInt64, mutable: Bool) {
        self.objectId = objectId
        self.initialSharedVersion = initialSharedVersion
        self.mutable = mutable
    }

    /// Initializes a new instance of `SharedObjectArg` from the provided JSON object.
    ///
    /// - Parameter input: A JSON object containing the required data.
    /// - Returns: An optional `SharedObjectArg`. Will be `nil` if any of the required fields are missing or invalid in the JSON object.
    public init?(input: JSON) {
        guard
            let objectId = input["objectId"].string,
            let initialSharedVersionString = input["initialSharedVersion"].string,
            let mutable = input["mutable"].bool,
            let initialSharedVersion = UInt64(initialSharedVersionString)
        else {
            return nil
        }
        self.objectId = objectId
        self.initialSharedVersion = initialSharedVersion
        self.mutable = mutable
    }

    public func serialize(_ serializer: Serializer) throws {
        let account = try AccountAddress.fromHex(self.objectId)
        try Serializer._struct(serializer, value: account)
        try Serializer.u64(serializer, self.initialSharedVersion)
        try Serializer.bool(serializer, self.mutable)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SharedObjectArg {
        let account: AccountAddress = try Deserializer._struct(deserializer)
        let initialSharedVersion = try Deserializer.u64(deserializer)
        let mutable = try deserializer.bool()
        return SharedObjectArg(objectId: account.hex(), initialSharedVersion: initialSharedVersion, mutable: mutable)
    }
}
