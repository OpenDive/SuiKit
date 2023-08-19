//
//  SharedObjectArg.swift
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
import SwiftyJSON

public struct SharedObjectArg: KeyProtocol {
    public let objectId: String
    public let initialSharedVersion: UInt64
    public let mutable: Bool

    public init(objectId: objectId, initialSharedVersion: UInt64, mutable: Bool) throws {
        self.objectId = objectId
        self.initialSharedVersion = initialSharedVersion
        self.mutable = mutable
    }

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
        let publicKey = try ED25519PublicKey(hexString: objectId)
        publicKey.serializeModule(serializer)
        try Serializer.u64(serializer, initialSharedVersion)
        try Serializer.bool(serializer, mutable)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SharedObjectArg {
        throw SuiError.notImplemented
    }
}
