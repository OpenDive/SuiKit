//
//  TypeTag.swift
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

/// Aptos Blockchain Type Tag
public struct TypeTag: KeyProtocol, Equatable {
    /// Boolean Type Tag
    public static let bool: Int = 0

    /// UInt8 Type Tag
    public static let u8: Int = 1

    /// UInt64 Type Tag
    public static let u64: Int = 2

    /// UInt128 Type Tag
    public static let u128: Int = 3

    /// AccountAddress Type Tag
    public static let accountAddress: Int = 4

    /// Signer Type Tag
    public static let signer: Int = 5

    /// Vector Type Tag
    public static let vector: Int = 6

    /// Struct Type Tag
    public static let _struct: Int = 7

    /// UInt16 Type Tag
    public static let u16: Int = 8

    /// UInt32 Type Tag
    public static let u32: Int = 9

    /// UInt256 Type Tag
    public static let u256: Int = 10

    /// The value itself
    let value: any TypeProtcol

    public init(value: any TypeProtcol) {
        self.value = value
    }

    public static func == (lhs: TypeTag, rhs: TypeTag) -> Bool {
        return lhs.value.variant() == rhs.value.variant()
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TypeTag {
        let variant = try deserializer.uleb128()

        if variant == TypeTag.bool {
            return TypeTag(value: try BoolTag.deserialize(from: deserializer))
        } else if variant == TypeTag.u8 {
            return TypeTag(value: try U8Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u16 {
            return TypeTag(value: try U16Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u32 {
            return TypeTag(value: try U32Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u64 {
            return TypeTag(value: try U64Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u128 {
            return TypeTag(value: try U128Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u256 {
            return TypeTag(value: try U256Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.accountAddress {
            return TypeTag(value: try AccountAddressTag.deserialize(from: deserializer))
        } else if variant == TypeTag._struct {
            return TypeTag(value: try StructTag.deserialize(from: deserializer))
        } else {
            throw AptosError.notImplemented
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.value.variant()))
        try Serializer._struct(serializer, value: self.value)
    }
}
