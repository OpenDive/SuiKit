//
//  TransactionBlockInput.swift
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

public struct TransactionBlockInput: KeyProtocol {
    /// Represents the position of the `TransactionBlockInput` in a collection.
    public var index: UInt16

    /// The value associated with the `TransactionBlockInput`, encapsulated in a `SuiJsonValue`.
    public var value: SuiJsonValue?

    /// The type of the value associated with the `TransactionBlockInput`.
    public var type: ValueType?

    /// Initializes a new instance of `TransactionBlockInput`.
    ///
    /// - Parameters:
    ///   - index: The position of the `TransactionBlockInput` in a collection.
    ///   - value: The value to be associated with the `TransactionBlockInput`. Defaults to `nil`.
    ///   - type: The type of the value to be associated with the `TransactionBlockInput`. Defaults to `nil`.
    public init(
        index: UInt16,
        value: SuiJsonValue? = nil,
        type: ValueType? = nil
    ) {
        self.index = index
        self.value = value
        self.type = type
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> TransactionBlockInput {
        return TransactionBlockInput(
            index: try Deserializer.u16(deserializer)
        )
    }
}
