//
//  MoveObject.swift
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

/// Represents a Move Object in Move programming language, detailing its fields, type, and whether it has public transfer enabled.
public struct MoveObject: Equatable {
    /// An optional `MoveStruct` representing the fields of the Move object.
    /// It is `nil` if the Move object does not have any fields.
    public var fields: JSON?

    /// A `Bool` indicating whether the Move object has public transfer enabled.
    public var hasPublicTransfer: Bool

    /// A `String` representing the type of the Move object.
    public var type: String

    public init(fields: JSON? = nil, hasPublicTransfer: Bool, type: String) {
        self.fields = fields
        self.hasPublicTransfer = hasPublicTransfer
        self.type = type
    }
}
