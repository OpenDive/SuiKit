//
//  GetPastObjectRequest.swift
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

/// Represents a request to retrieve a past object, conforming to `Codable` to support encoding and decoding.
public struct GetPastObjectRequest: Codable {
    /// A `String` representing the unique identifier of the object to be retrieved.
    public var objectId: String

    /// A `String` representing the version of the object to be retrieved.
    public var version: String

    /// Initializes a new instance of `GetPastObjectRequest`.
    /// - Parameters:
    ///   - objectId: A `String` representing the unique identifier of the object.
    ///   - version: A `String` representing the version of the object.
    public init(objectId: String, version: String) {
        self.objectId = objectId
        self.version = version
    }
}
