//
//  InputType.swift
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

/// An `InputType` enum encapsulates the different types of input arguments.
/// This enum conforms to the `KeyProtocol`, meaning it satisfies certain requirements for being used as a key type.
public indirect enum InputType: KeyProtocol {
    /// Represents a "pure" call argument, meaning the argument does not include any object references.
    case pure(PureCallArg)

    /// Represents an object argument, meaning the argument includes an object reference.
    case object(ObjectArg)

    // TODO: Implement Object Vector type

    /// A static function to create an `InputType` instance from a JSON object.
    ///
    /// - Parameter input: The JSON object containing the input data.
    /// - Returns: An optional `InputType` if the JSON could be parsed, otherwise `nil`.
    public static func fromJSON(_ input: JSON) -> InputType? {
        switch input["type"].stringValue {
        case "pure":
            guard let pure = PureCallArg(input: input) else { return nil }
            return .pure(pure)
        case "object":
            guard let object = ObjectArg.fromJSON(input) else { return nil }
            return .object(object)
        default:
            return nil
        }
    }

    /// Serializes the `InputType` using the provided `Serializer`.
    ///
    /// - Parameter serializer: The `Serializer` to use for the serialization.
    /// - Throws: Throws an error if the serialization fails.
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .pure(let pure):
            try serializer.uleb128(UInt(0))
            try Serializer._struct(serializer, value: pure)
        case .object(let object):
            try serializer.uleb128(UInt(1))
            try Serializer._struct(serializer, value: object)
        }
    }

    /// A static function to deserialize an `InputType` instance from a `Deserializer`.
    ///
    /// - Parameter deserializer: The `Deserializer` to use for the deserialization.
    /// - Returns: A deserialized `InputType` instance.
    /// - Throws: Throws `SuiError.customError(message: "Unable to Deserialize")` if the deserialization fails.
    public static func deserialize(from deserializer: Deserializer) throws -> InputType {
        let value = try Deserializer.u8(deserializer)
        switch value {
        case 0:
            return .pure(try Deserializer._struct(deserializer))
        case 1:
            return .object(try Deserializer._struct(deserializer))
        default:
            throw SuiError.customError(message: "Unable to Deserialize")
        }
    }
}
