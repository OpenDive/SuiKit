//
//  MoveStruct.swift
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

/// `MoveStruct` represents the possible types of structures in the Move programming language.
public enum MoveStruct {
    /// Represents an array of `MoveValue` items. Suitable for handling Move's native vector type.
    case fieldArray([MoveValue])

    /// Represents a single field type defined by `MoveFieldType`.
    case fieldType(MoveFieldType)

    /// Represents a map from field names (as `String`) to their corresponding `MoveValue` objects. This is suitable for handling Move's native struct type.
    case fieldMap([String: MoveValue])

    /// Parses a `JSON` object to produce a `MoveStruct` object if possible.
    ///
    /// - Parameters:
    ///   - input: The JSON object representing the Move structure.
    /// - Returns: A `MoveStruct` object if parsing is successful; otherwise returns `nil`.
    ///
    /// This method attempts to parse the provided JSON into a `MoveStruct` by checking for
    /// various expected structures such as arrays, maps, or field types.
    public static func parseJSON(_ input: JSON) -> MoveStruct? {
        // If the input JSON contains a dictionary (map), process it
        if !(input.dictionaryValue.isEmpty) {
            var fieldsMap: [String: MoveValue] = [:]
            for (fieldKey, fieldValue) in input.dictionaryValue {
                fieldsMap[fieldKey] = MoveValue.parseJSON(fieldValue)
            }
            return .fieldMap(fieldsMap)
        }

        // If the input JSON is an array, process it
        if let array = input.array {
            return .fieldArray(array.map { MoveValue.parseJSON($0) })
        }

        // If the input JSON contains a type, process it
        if input["type"].exists() {
            return .fieldType(MoveFieldType(input: input))
        }

        // If none of the above conditions are met, return nil
        return nil
    }
}
