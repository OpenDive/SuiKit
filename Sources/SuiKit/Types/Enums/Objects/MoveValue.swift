//
//  MoveValue.swift
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

/// `MoveValue` represents the possible types of values in the Move programming language.
public enum MoveValue {
    /// Represents a numerical value. The associated value is an `Int`.
    case number(Int)

    /// Represents a boolean value. The associated value is a `Bool`.
    case boolean(Bool)

    /// Represents a string value. The associated value is a `String`.
    case string(String)

    /// Represents an array of `MoveValue` items.
    case moveValues([MoveValue])

    /// Represents an identifier for a value, defined by `MoveValueId`.
    case id(MoveValueId)

    /// Represents a Move structure, defined by `MoveStruct`.
    case moveStruct(MoveStruct)

    /// Represents a null value.
    case null

    /// Parses a `JSON` object to produce a `MoveValue` object.
    ///
    /// - Parameters:
    ///   - input: The JSON object representing the Move value.
    /// - Returns: A `MoveValue` object based on the parsed JSON.
    ///
    /// This method attempts to parse the provided JSON into a `MoveValue` by checking for
    /// various expected types such as numbers, booleans, strings, arrays, identifiers, and structures.
    public static func parseJSON(_ input: JSON) -> MoveValue {
        // If the input JSON is a number, process it
        if let number = input.int {
            return .number(number)
        }

        // If the input JSON is a boolean, process it
        if let bool = input.bool {
            return .boolean(bool)
        }

        // If the input JSON is a string, process it
        if let string = input.string {
            return .string(string)
        }

        // If the input JSON is an array, process it
        if let array = input.array {
            return .moveValues(array.map { MoveValue.parseJSON($0) })
        }

        // If the input JSON contains an id, process it
        if input["id"].exists() {
            return .id(MoveValueId(input: input))
        }

        // If the input JSON contains a structure, process it
        if let structure = MoveStruct.parseJSON(input) {
            return .moveStruct(structure)
        }

        // If none of the above conditions are met, return null
        return .null
    }
}
