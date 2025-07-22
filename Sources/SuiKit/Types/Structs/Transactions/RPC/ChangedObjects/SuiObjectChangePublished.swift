//
//  SuiObjectChangePublished.swift
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

public struct SuiObjectChangePublished {
    /// A constant `String` representing the type of object change, which is "published".
    public let type: String = "published"

    /// An `objectId` representing the ID of the package.
    public let packageId: ObjectId

    /// A `SequenceNumber` representing the version number of the published object.
    public let version: SequenceNumber

    /// An `ObjectDigest` representing the digest of the published object.
    public let digest: ObjectDigest

    /// An array of `String` objects representing the modules that were published.
    public let modules: [String]

    public init(input: JSON) {
        self.packageId = input["packageId"].stringValue
        self.version = input["version"].stringValue
        self.digest = input["digest"].stringValue
        self.modules = input["modules"].arrayValue.map { $0.stringValue }
    }
}
