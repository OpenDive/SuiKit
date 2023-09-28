//
//  SuiObjectData.swift
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

/// A structure representing SuiObjectData, containing various information about an object.
public struct SuiObjectData {
    /// An optional `RawData` representing the Binary Canonical Serialization (BCS) of the object.
    public let bcs: RawData?

    /// An optional `SuiParsedData` representing the parsed data of the object.
    public let content: SuiParsedData?

    /// A `String` representing the digest of the object.
    public let digest: String

    /// An optional `DisplayFieldsResponse` representing the display fields of the object.
    public let display: DisplayFieldsResponse?

    /// A `String` representing the object ID.
    public let objectId: String

    /// An optional `ObjectOwner` representing the owner of the object.
    public let owner: ObjectOwner?

    /// An optional `String` representing the previous transaction of the object.
    public let previousTransaction: String?

    /// An optional `Int` representing the storage rebate of the object.
    public let storageRebate: Int?

    /// An optional `String` representing the type of the object.
    public let type: String?

    /// A `String` representing the version of the object.
    public let version: String

    public init(
        bcs: RawData?,
        content: SuiParsedData?,
        digest: String,
        display: DisplayFieldsResponse?,
        objectId: String,
        owner: ObjectOwner?,
        previousTransaction: String?,
        storageRebate: Int?,
        type: String?,
        version: String
    ) {
        self.bcs = bcs
        self.content = content
        self.digest = digest
        self.display = display
        self.objectId = objectId
        self.owner = owner
        self.previousTransaction = previousTransaction
        self.storageRebate = storageRebate
        self.type = type
        self.version = version
    }

    public init?(data: JSON) {
        self.bcs = RawData.parseJSON(data["bcs"])
        self.content = SuiParsedData.parseJSON(data["content"])
        self.digest = data["digest"].stringValue
        self.display = DisplayFieldsResponse.parseJSON(data["display"])
        self.objectId = data["objectId"].stringValue
        self.owner = ObjectOwner.parseJSON(data["owner"])
        self.previousTransaction = data["previousTransaction"].stringValue
        self.storageRebate = data["storageRebate"].int
        self.type = data["type"].string
        self.version = data["version"].stringValue
    }
}
