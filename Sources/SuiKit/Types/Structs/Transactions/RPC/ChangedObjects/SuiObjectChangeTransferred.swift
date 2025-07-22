//
//  SuiObjectChangeTransferred.swift
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

public struct SuiObjectChangeTransferred {
    /// A constant `String` representing the type of object change, which is "transferred".
    public let type: String = "transferred"

    /// An `AccountAddress` representing the sender who has transferred the object.
    public let sender: AccountAddress

    /// An `ObjectOwner` type representing the receiver of the object.
    public let recipient: ObjectOwner

    /// A `String` representing the object type that was transferred.
    public let objectType: String

    /// An `ObjectId` type representing the ID of the object transferred.
    public let objectId: ObjectId

    /// A `SequenceNumber` representing the version number of the object transferred.
    public let version: SequenceNumber

    /// The `ObjectDigest` type representing the digest of the object transferred.
    public let digest: ObjectDigest

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        guard let recipient = ObjectOwner.parseJSON(input["recipient"]) else { return nil }
        self.sender = sender
        self.recipient = recipient
        self.objectType = input["objectType"].stringValue
        self.objectId = input["objectId"].stringValue
        self.version = input["version"].stringValue
        self.digest = input["digest"].stringValue
    }
}
