//
//  PureCallArg.swift
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

/// A structure representing an argument for a Pure Call, conforming to `KeyProtocol`.
public struct PureCallArg: KeyProtocol {
    /// An array of `UInt8` representing the value of the argument.
    public var value: [UInt8]

    /// Initializes a new instance of `PureCallArg`.
    ///
    /// - Parameter value: An array of `UInt8` representing the value of the argument.
    public init(value: [UInt8]) {
        self.value = value
    }

    /// Initializes a new instance of `PureCallArg`.
    ///
    /// - Parameter value: A `Data` object representing the value of the argument.
    public init(value: Data) {
        self.value = [UInt8](value)
    }

    /// Initializes a new instance of `PureCallArg` from the provided JSON object.
    ///
    /// - Parameter input: A JSON object containing the required data.
    /// - Returns: An optional `PureCallArg`. Will be `nil` if any of the required fields are missing or invalid in the JSON object.
    public init?(input: JSON) {
        guard let value = SuiJsonValue.fromJSON(input["value"]) else { return nil }
        let ser = Serializer()
        guard (try? Serializer._struct(ser, value: value)) != nil else { return nil }
        self.value = [UInt8](ser.output())
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(self.value, Serializer.u8)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> PureCallArg {
        return PureCallArg(
            value: try deserializer.sequence(valueDecoder: Deserializer.u8)
        )
    }
}
