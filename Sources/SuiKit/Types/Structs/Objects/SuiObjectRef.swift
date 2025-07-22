//
//  SuiObjectRef.swift
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

/// Represents a reference to a Sui Object and conforms to `KeyProtocol`.
public struct SuiObjectRef: KeyProtocol {
    /// A `String` representing the object ID of the Sui Object.
    public var objectId: String

    /// A `String` representing the version of the Sui Object.
    public var version: String

    /// A `TransactionDigest` representing the digest related to the Sui Object transaction.
    public var digest: TransactionDigest

    /// Initializes a new instance of `SuiObjectRef`.
    /// - Parameters:
    ///   - objectId: A `String` representing the object ID of the Sui Object.
    ///   - version: A `String` representing the version of the Sui Object.
    ///   - digest: A `TransactionDigest` representing the transaction digest.
    public init(
        objectId: ObjectId,
        version: String,
        digest: TransactionDigest
    ) {
        self.objectId = objectId
        self.version = version
        self.digest = digest
    }

    /// Initializes a new instance of `SuiObjectRef` with `AccountAddress` as object ID.
    /// - Parameters:
    ///   - objectId: An `AccountAddress` representing the object ID of the Sui Object.
    ///   - version: A `String` representing the version of the Sui Object.
    ///   - digest: A `TransactionDigest` representing the transaction digest.
    public init(
        objectId: AccountAddress,
        version: String,
        digest: TransactionDigest
    ) {
        self.objectId = objectId.hex()
        self.version = version
        self.digest = digest
    }

    /// Initializes a new instance of `SuiObjectRef` from a JSON object.
    /// - Parameter input: A `JSON` object containing the initial values for the new instance.
    public init(input: JSON) {
        self.objectId = input["objectId"].stringValue
        self.version = "\(input["version"].uInt64Value)"
        self.digest = input["digest"].stringValue
    }

    public func serialize(_ serializer: Serializer) throws {
        let account = try AccountAddress.fromHex(self.objectId)
        try Serializer._struct(serializer, value: account)
        try Serializer.u64(serializer, UInt64(version) ?? 0)
        if let dataDigest = digest.base58DecodedData {
            try Serializer.toBytes(serializer, Data(dataDigest))
        }
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> SuiObjectRef {
        return SuiObjectRef(
            objectId: try Deserializer._struct(deserializer),
            version: "\(try Deserializer.u64(deserializer))",
            digest: ([UInt8](try Deserializer.toBytes(deserializer))).base58EncodedString
        )
    }
}
