//
//  SuiObjectChangeMutated.swift
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

public struct SuiObjectChangeMutated {
    /// A constant `String` representing the type of object change, which is "mutated".
    public let type: String = "mutated"

    /// An `AccountAddress` representing the sender who has mutated the object.
    public let sender: AccountAddress

    /// An `ObjectOwner` representing the owner of the mutated object.
    public let owner: ObjectOwner

    /// A `String` representing the type of the mutated object.
    public let objectType: String

    /// A `SequenceNumber` representing the version of the mutated object.
    public let version: SequenceNumber

    /// A `SequenceNumber` representing the previous version of the mutated object.
    public let previousVersion: SequenceNumber

    /// An `ObjectDigest` representing the digest of the mutated object.
    public let digest: ObjectDigest

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        guard let owner = ObjectOwner.parseJSON(input["owner"]) else { return nil }
        self.sender = sender
        self.owner = owner
        self.objectType = input["objectType"].stringValue
        self.version = input["version"].stringValue
        self.previousVersion = input["previousVersion"].stringValue
        self.digest = input["digest"].stringValue
    }
}
