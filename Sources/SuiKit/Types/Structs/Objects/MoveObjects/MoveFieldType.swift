//
//  MoveFieldType.swift
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

/// Represents the field type in Move, containing the fields and their types.
public struct MoveFieldType {
    /// A dictionary where keys are the names of the fields and values are the `MoveValue` associated with each field.
    public var fields: [String: MoveValue]

    /// A `String` representing the type of the Move field.
    public var type: String

    /// Initializes a new instance of `MoveFieldType` using a given JSON input.
    /// It parses the input JSON to populate the `fields` and `type` properties.
    ///
    /// - Parameter input: A `JSON` object containing the information to initialize the `MoveFieldType`.
    public init(input: JSON) {
        var fieldsOutput: [String: MoveValue] = [:]
        for (key, value) in input["fields"].dictionaryValue {
            fieldsOutput[key] = MoveValue.parseJSON(value)
        }
        self.fields = fieldsOutput
        self.type = input["type"].stringValue
    }
}
