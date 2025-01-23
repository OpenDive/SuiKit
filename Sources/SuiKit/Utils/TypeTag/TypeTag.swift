//
//  TypeTag.swift
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

/// Sui Blockchain Type Tag
public struct TypeTag: KeyProtocol, Equatable {
    /// Boolean Type Tag
    public static let bool: UInt8 = 0

    /// UInt8 Type Tag
    public static let u8: UInt8 = 1

    /// UInt64 Type Tag
    public static let u64: UInt8 = 2

    /// UInt128 Type Tag
    public static let u128: UInt8 = 3

    /// AccountAddress Type Tag
    public static let accountAddress: UInt8 = 4

    /// Signer Type Tag
    public static let signer: UInt8 = 5

    /// Vector Type Tag
    public static let vector: UInt8 = 6

    /// Struct Type Tag
    public static let _struct: UInt8 = 7

    /// UInt16 Type Tag
    public static let u16: UInt8 = 8

    /// UInt32 Type Tag
    public static let u32: UInt8 = 9

    /// UInt256 Type Tag
    public static let u256: UInt8 = 10

    let type: UInt8

    /// The value itself
    let value: TypeProtocol?

    public init(value: any TypeProtocol) throws {
        self.value = value

        if value is StructTag {
            self.type = Self._struct
        } else if value is AccountAddressTag {
            self.type = Self.accountAddress
        } else {
            throw SuiError.notImplemented
        }
    }

    public init(stringValue: String) throws {
        if let structTag = try? StructTag.fromStr(stringValue) {
            self.value = structTag
            self.type = Self._struct
        } else if let accountAddress = try? AccountAddress.fromHex(stringValue) {
            self.value = AccountAddressTag(value: accountAddress)
            self.type = Self.accountAddress
        } else if stringValue == "bool" {
            self.type = Self.bool
            self.value = nil
        } else if stringValue == "u8" {
            self.type = Self.u8
            self.value = nil
        } else if stringValue == "u16" {
            self.type = Self.u16
            self.value = nil
        } else if stringValue == "u32" {
            self.type = Self.u32
            self.value = nil
        } else if stringValue == "u64" {
            self.type = Self.u64
            self.value = nil
        } else if stringValue == "u128" {
            self.type = Self.u128
            self.value = nil
        } else if stringValue == "u256" {
            self.type = Self.u256
            self.value = nil
        } else {
            throw SuiError.notImplemented
        }
    }

    public init(type: UInt8) {
        self.type = type
        self.value = nil
    }

    public static func == (lhs: TypeTag, rhs: TypeTag) -> Bool {
        let result = lhs.type == rhs.type

        if let lhsValue = lhs.value, let rhsValue = rhs.value {
            if lhsValue is StructTag && rhsValue is StructTag {
                return result && (lhsValue as! StructTag) == (rhsValue as! StructTag)
            }

            if lhsValue is AccountAddressTag && rhsValue is AccountAddressTag {
                return result && (lhsValue as! AccountAddressTag) == (rhsValue as! AccountAddressTag)
            }

            return false
        }

        return result
    }

    public func toString() throws -> String {
        let variant = self.value?.variant()

        if let variant {
            if variant == TypeTag.accountAddress {
                return "address"
            } else if variant == TypeTag._struct {
                return "struct"
            }
        }

        if self.type == TypeTag.bool {
            return "bool"
        } else if self.type == TypeTag.u8 {
            return "u8"
        } else if self.type == TypeTag.u16 {
            return "u16"
        } else if self.type == TypeTag.u32 {
            return "u32"
        } else if self.type == TypeTag.u64 {
            return "u64"
        } else if self.type == TypeTag.u128 {
            return "u128"
        } else if self.type == TypeTag.u256 {
            return "u256"
        } else {
            throw SuiError.notImplemented
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TypeTag {
        let variant = try Deserializer.u8(deserializer)

        if variant == TypeTag.bool {
            return TypeTag(type: Self.bool)
        } else if variant == TypeTag.u8 {
            return TypeTag(type: Self.u8)
        } else if variant == TypeTag.u16 {
            return TypeTag(type: Self.u16)
        } else if variant == TypeTag.u32 {
            return TypeTag(type: Self.u32)
        } else if variant == TypeTag.u64 {
            return TypeTag(type: Self.u64)
        } else if variant == TypeTag.u128 {
            return TypeTag(type: Self.u128)
        } else if variant == TypeTag.u256 {
            return TypeTag(type: Self.u256)
        } else if variant == TypeTag.accountAddress {
            return try TypeTag(value: try AccountAddressTag.deserialize(from: deserializer))
        } else if variant == TypeTag._struct {
            return try TypeTag(value: try StructTag.deserialize(from: deserializer))
        } else {
            throw SuiError.notImplemented
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, self.type)
        if let value = self.value { try Serializer._struct(serializer, value: value) }
    }
}
