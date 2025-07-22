//
//  SuiMoveNormalizedType.swift
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

/// An enumeration that represents various types that can be encountered in the SuiMove environment.
/// Conforms to `Equatable` and `KeyProtocol`.
public indirect enum SuiMoveNormalizedType: Equatable, KeyProtocol {
    /// Represents a boolean type.
    case bool

    /// Represents an 8-bit unsigned integer.
    case u8

    /// Represents a 16-bit unsigned integer.
    case u16

    /// Represents a 32-bit unsigned integer.
    case u32

    /// Represents a 64-bit unsigned integer.
    case u64

    /// Represents a 128-bit unsigned integer.
    case u128

    /// Represents a 256-bit unsigned integer.
    case u256

    /// Represents an address type.
    case address

    /// Represents a signer type.
    case signer

    /// Represents a generic type parameter.
    case typeParameter(TypeParameter)

    /// Represents an immutable reference to a type.
    case reference(SuiMoveNormalizedType)

    /// Represents a mutable reference to a type.
    case mutableReference(SuiMoveNormalizedType)

    /// Represents a vector of a type.
    case vector(SuiMoveNormalizedType)

    /// Represents a structured type.
    case structure(SuiMoveNormalizedStructType)

    /// Function to determine the pure serialization type based on the argument value.
    /// - Parameter argVal: The JSON value of the argument.
    /// - Throws: Throws `SuiError.typeArgumentIsEmpty` if type argument is empty.
    /// - Returns: Returns a string representation of the pure serialization type if it exists, otherwise returns `nil`.
    public func getPureSerializationType(_ argVal: SuiJsonValue) throws -> String? {
        switch self {
        case .bool:
            return self.kind.lowercased()
        case .u8, .u16, .u32, .u64, .u128, .u256:
            return self.kind.lowercased()
        case .address, .signer:
            return self.kind.lowercased()
        case .vector(let normalizedTypeVector):
            if argVal.kind == .string, normalizedTypeVector.kind == "U8" {
                return "string"
            }
            let innerType = try normalizedTypeVector.getPureSerializationType(argVal)
            guard innerType != nil else { return nil }
            return "vector<\(innerType!)>"
        case .structure(let normalizedStruct):
            if normalizedStruct.isSameStruct(ResolvedAsciiStr()) {
                return "string"
            }
            if normalizedStruct.isSameStruct(ResolvedUtf8Str()) {
                return "utf8string"
            }
            if normalizedStruct.isSameStruct(ResolvedSuiId()) {
                return "address"
            }
            if normalizedStruct.isSameStruct(ResolvedStdOption()) {
                guard !(normalizedStruct.typeArguments.isEmpty) else { throw SuiError.customError(message: "Type argument is empty") }
                let optionToVec: SuiMoveNormalizedType = .vector(normalizedStruct.typeArguments[0])

                return try optionToVec.getPureSerializationType(argVal)
            }
        default:
            return nil
        }
        return nil
    }

    /// Function to extract mutable references from the normalized type.
    /// - Returns: Returns the mutable reference type if it exists, otherwise returns `nil`.
    public func extractMutableReference() -> SuiMoveNormalizedType? {
        switch self {
        case .mutableReference(let suiMoveNormalizedType):
            return suiMoveNormalizedType
        default:
            return nil
        }
    }

    /// Function to extract structure tags from the normalized type.
    /// - Returns: Returns the structure type if it exists, otherwise returns `nil`.
    public func extractStructTag() -> SuiMoveNormalizedStructType? {
        switch self {
        case .reference(let suiMoveNormalizedType):
            switch suiMoveNormalizedType {
            case .structure(let structure):
                return structure
            default:
                return nil
            }
        case .mutableReference(let suiMoveNormalizedType):
            switch suiMoveNormalizedType {
            case .structure(let structure):
                return structure
            default:
                return nil
            }
        case .structure(let structure):
                return structure
        default:
            return nil
        }
    }

    /// A string representation of the kind of the type.
    public var kind: String {
        switch self {
        case .bool:
            return "Bool"
        case .u8:
            return "U8"
        case .u16:
            return "U16"
        case .u32:
            return "U32"
        case .u64:
            return "U64"
        case .u128:
            return "U128"
        case .u256:
            return "U256"
        case .address:
            return "Address"
        case .signer:
            return "Signer"
        case .typeParameter:
            return "TypeParameter"
        case .reference:
            return "Reference"
        case .mutableReference:
            return "MutableReference"
        case .vector:
            return "Vector"
        case .structure:
            return "Structure"
        }
    }

    public static func parseGraphQL(_ data: AnyHashable) -> SuiMoveNormalizedType? {
        if JSON(data)["ref"].exists() && JSON(data)["ref"].string == "&mut" {
            guard let mutableReference = Self.parseGraphQLInner(data) else { return nil }
            return .mutableReference(mutableReference)
        }
        if JSON(data)["ref"].exists() && JSON(data)["ref"].string == "&" {
            guard let reference = Self.parseGraphQLInner(data) else { return nil }
            return .reference(reference)
        }
        return parseGraphQLInner(data)
    }

    internal static func parseGraphQLInner(_ data: AnyHashable? = nil, _ override: JSON? = nil) -> SuiMoveNormalizedType? {
        let json = data != nil ? JSON(data!) : JSON()
        var body = json["body"]
        if override != nil { body = override! }
        switch body.stringValue {
        case "bool":
            return .bool
        case "u8":
            return .u8
        case "u16":
            return .u16
        case "u32":
            return .u32
        case "u64":
            return .u64
        case "u128":
            return .u128
        case "u256":
            return .u256
        case "address":
            return .address
        default:
            break
        }
        if body["datatype"].exists() {
            guard let structure = SuiMoveNormalizedStructType(graphQLInput: body["datatype"]) else { return nil }
            return .structure(
                structure
            )
        }
        if body["vector"].exists() {
            guard let vector = Self.parseGraphQLInner(nil, body["vector"]) else { return nil }
            return .vector(vector)
        }
        if body["typeParameter"].exists() {
            return .typeParameter(
                TypeParameter(
                    typeParameter: UInt16(body["typeParameter"].int16Value)
                )
            )
        }

        return nil
    }

    /// Function to parse JSON into a `SuiMoveNormalizedType`.
    /// - Parameter data: The JSON data to parse.
    /// - Returns: Returns a `SuiMoveNormalizedType` if it could be parsed, otherwise returns `nil`.
    public static func parseJSON(_ data: JSON) -> SuiMoveNormalizedType? {
        switch data.stringValue {
        case "Bool":
            return .bool
        case "U8":
            return .u8
        case "U16":
            return .u16
        case "U32":
            return .u32
        case "U64":
            return .u64
        case "U128":
            return .u128
        case "U256":
            return .u256
        case "Address":
            return .address
        case "Signer":
            return .signer
        default:
            if data["MutableReference"].exists() {
                guard let mutableReference = Self.parseJSON(data["MutableReference"]) else { return nil }
                return .mutableReference(mutableReference)
            }
            if data["Reference"].exists() {
                guard let reference = Self.parseJSON(data["Reference"]) else { return nil }
                return .reference(reference)
            }
            if data["Struct"].exists() {
                guard let structure = SuiMoveNormalizedStructType(input: data["Struct"]) else { return nil }
                return .structure(
                    structure
                )
            }
            if data["Vector"].exists() {
                guard let vector = Self.parseJSON(data["Vector"]) else { return nil }
                return .vector(vector)
            }
            if data["TypeParameter"].exists() {
                return .typeParameter(
                    TypeParameter(
                        typeParameter: UInt16(data["TypeParameter"].int16Value)
                    )
                )
            }
            return nil
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .bool:
            try Serializer.u8(serializer, UInt8(0))
        case .u8:
            try Serializer.u8(serializer, UInt8(1))
        case .u16:
            try Serializer.u8(serializer, UInt8(2))
        case .u32:
            try Serializer.u8(serializer, UInt8(3))
        case .u64:
            try Serializer.u8(serializer, UInt8(4))
        case .u128:
            try Serializer.u8(serializer, UInt8(5))
        case .u256:
            try Serializer.u8(serializer, UInt8(6))
        case .address:
            try Serializer.u8(serializer, UInt8(7))
        case .signer:
            try Serializer.u8(serializer, UInt8(8))
        case .typeParameter(let typeParameter):
            try Serializer.u8(serializer, UInt8(9))
            try Serializer._struct(serializer, value: typeParameter)
        case .reference(let suiMoveNormalizedType):
            try Serializer.u8(serializer, UInt8(10))
            try Serializer._struct(serializer, value: suiMoveNormalizedType)
        case .mutableReference(let suiMoveNormalizedType):
            try Serializer.u8(serializer, UInt8(11))
            try Serializer._struct(serializer, value: suiMoveNormalizedType)
        case .vector(let suiMoveNormalizedType):
            try Serializer.u8(serializer, UInt8(12))
            try Serializer._struct(serializer, value: suiMoveNormalizedType)
        case .structure(let suiMoveNormalizedStructType):
            try Serializer.u8(serializer, UInt8(13))
            try Serializer._struct(serializer, value: suiMoveNormalizedStructType)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiMoveNormalizedType {
        let value = try Deserializer.u8(deserializer)

        switch value {
        case 0:
            return .bool
        case 1:
            return .u8
        case 2:
            return .u16
        case 3:
            return .u32
        case 4:
            return .u64
        case 5:
            return .u128
        case 6:
            return .u256
        case 7:
            return .address
        case 8:
            return .signer
        case 9:
            return .typeParameter(try Deserializer._struct(deserializer))
        case 10:
            return .reference(try Deserializer._struct(deserializer))
        case 11:
            return .mutableReference(try Deserializer._struct(deserializer))
        case 12:
            return .vector(try Deserializer._struct(deserializer))
        case 13:
            return .structure(try Deserializer._struct(deserializer))
        default:
            throw SuiError.customError(message: "Unable to Deserialize")
        }
    }
}
