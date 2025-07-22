//
//  Input.swift
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

/// A structure representing an Input conforming to `KeyProtocol`.
public struct Input: KeyProtocol {
    /// Represents the type of the input, could be object or pure.
    public var inputType: InputType

    /// Initializes a new instance of `Input`.
    ///
    /// - Parameter inputType: The type of the input.
    public init(type: InputType) {
        self.inputType = type
    }

    /// Initializes a new instance of `Input` from the provided JSON object.
    ///
    /// - Parameter input: A JSON object containing the required data.
    /// - Returns: An optional `Input`. Will be `nil` if the type field is missing or invalid in the JSON object.
    public init?(input: JSON) {
        switch input["type"].stringValue {
        case "object":
            guard let object = ObjectArg.fromJSON(input) else { return nil }
            self.inputType = .object(object)
        case "pure":
            guard let pure = PureCallArg(input: input) else { return nil }
            self.inputType = .pure(pure)
        default:
            return nil
        }
    }

    /// Returns the kind of input as a string.
    public var kind: String {
        switch inputType {
        case .pure:
            return "pure"
        case .object:
            return "object"
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.inputType)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Input {
        return Input(type: try Deserializer._struct(deserializer))
    }
}

public extension Input {
    /// Determines whether the input is a mutable shared object or not.
    ///
    /// - Returns: A boolean value indicating whether the input is a mutable shared object.
    func isMutableSharedObjectInput() -> Bool {
        return self.getSharedObjectInput()?.mutable ?? false
    }

    /// Retrieves the shared object input if available.
    ///
    /// - Returns: An optional `SharedObjectArg`. Will be `nil` if the input type is not a shared object.
    func getSharedObjectInput() -> SharedObjectArg? {
        switch self.inputType {
        case .object(let object):
            switch object {
            case .shared(let sharedArg):
                return sharedArg
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
