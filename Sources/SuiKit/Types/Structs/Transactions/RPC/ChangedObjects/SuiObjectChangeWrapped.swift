//
//  SuiObjectChangeWrapped.swift
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

public struct SuiObjectChangeWrapped {
    /// A constant `String` representing the type of object change, which is "wrapped".
    public let type: String = "wrapped"

    /// An `AccountAddress` type representing the sender of the wrapped object.
    public let sender: AccountAddress

    /// A `String` type representing the object type of the object wrapped.
    public let objectType: String

    /// The `ObjectId` type representing the ID of the object wrapped.
    public let objectId: ObjectId

    /// The `SequenceNumber` type representing the version of the wrapped object.
    public let version: SequenceNumber

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        self.sender = sender
        self.objectType = input["objectType"].stringValue
        self.objectId = input["objectId"].stringValue
        self.version = input["version"].stringValue
    }
}
