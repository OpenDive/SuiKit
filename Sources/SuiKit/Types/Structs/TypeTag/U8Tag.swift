//
//  U8Tag.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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

/// UInt8 Type Tag
public struct U8Tag: TypeProtcol, Equatable {
    /// The value itself
    let value: Int

    public static func ==(lhs: U8Tag, rhs: U8Tag) -> Bool {
        return lhs.value == rhs.value
    }

    public func variant() -> Int {
        return TypeTag.u8
    }

    public static func deserialize(from deserializer: Deserializer) throws -> U8Tag {
        return try U8Tag(value: Int(Deserializer.u8(deserializer)))
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, UInt8(self.value))
    }
}
