//
//  MoveObjectRaw.swift
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

/// Represents a raw Move Object in the Move programming language, containing its BCS (Binary Canonical Serialization) representation, type, version, and whether it has public transfer enabled.
public struct MoveObjectRaw: Equatable {
    /// A `String` representing the BCS (Binary Canonical Serialization) bytes of the Move object.
    /// BCS is a binary format used for encoding structured data.
    public var bcsBytes: String

    /// A `Bool` indicating whether the Move object has public transfer enabled.
    public var hasPublicTransfer: Bool

    /// A `String` representing the type of the Move object.
    public var type: String

    /// A `String` representing the version of the Move object.
    public var version: String

    public init(bcsBytes: String, hasPublicTransfer: Bool, type: String, version: String) {
        self.bcsBytes = bcsBytes
        self.hasPublicTransfer = hasPublicTransfer
        self.type = type
        self.version = version
    }
}
