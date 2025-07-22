//
//  NestedResult.swift
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

public struct NestedResult: KeyProtocol {
    /// The index representing the position of the `NestedResult` in a collection.
    public let index: UInt16

    /// The index representing the position of the result in a collection.
    public let resultIndex: UInt16

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
        try Serializer.u16(serializer, resultIndex)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> NestedResult {
        return NestedResult(
            index: try Deserializer.u16(deserializer),
            resultIndex: try Deserializer.u16(deserializer)
        )
    }
}
