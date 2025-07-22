//
//  StructTag.swift
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

/// Struct Type Tag
public struct StructTag: TypeProtocol, Equatable {
    let value: StructTagValue

    public static func ==(lhs: StructTag, rhs: StructTag) -> Bool {
        return lhs.value == rhs.value
    }

    public func variant() -> UInt8 {
        return TypeTag._struct
    }

    /// Deserialize a StructTag instance from a string representation.
    ///
    /// This function deserializes the given string representation of a StructTag instance to a StructTag object.
    ///
    /// - Parameters:
    ///    - typeTag: A string representation of the StructTag instance to be deserialized.
    ///
    /// - Returns: A StructTag instance that has been deserialized from the given string representation.
    ///
    /// - Throws: An AptosError indicating that the given string representation is invalid and cannot be deserialized to a StructTag instance.
    public static func fromStr(_ typeTag: String) throws -> StructTag {
        var name = ""
        var index = 0
        var nestedValue: TypeTag?

        while index < typeTag.count {
            let letter = typeTag[typeTag.index(typeTag.startIndex, offsetBy: index)]
            index += 1
            if letter == "<" {
                nestedValue = try TypeTag(stringValue: typeTag[index..<typeTag.count])
                break
            } else if letter == ">" {
                break
            } else {
                name.append(letter)
            }
        }
        let split = name.components(separatedBy: "::")
        return try StructTag(
            value: StructTagValue(
                address: AccountAddress.fromHex(String(split[0])),
                module: String(split[1]),
                name: String(split[2]),
                typeArgs: nestedValue != nil ? [nestedValue!] : []
            )
        )
    }

    public func toString() throws -> String {
        let value = self.value
        let formattedTypeParams =
        !value.typeArgs.isEmpty ?
        "<\(try value.typeArgs.map({ try $0.toString() }).joined(separator: ","))>" :
        ""
        return "\(value.address)::\(value.module)::\(value.name)\(formattedTypeParams)"
    }

    public static func deserialize(from deserializer: Deserializer) throws -> StructTag {
        _ = try Deserializer.u8(deserializer)
        let address: AccountAddress = try Deserializer._struct(deserializer)
        let module = try Deserializer.string(deserializer)
        let name = try Deserializer.string(deserializer)
        let typeArgs: [TypeTag] = try deserializer.sequence(valueDecoder: TypeTag.deserialize)

        return StructTag(
            value: StructTagValue(
                address: address,
                module: module,
                name: name,
                typeArgs: typeArgs
            )
        )
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.value.address.serialize(serializer)
        try Serializer.str(serializer, self.value.module)
        try Serializer.str(serializer, self.value.name)
        try serializer.sequence(self.value.typeArgs, Serializer._struct)
    }
}

/// The value contents of a Struct Tag
public struct StructTagValue: Equatable {
    /// The account address
    let address: AccountAddress

    /// The module type
    let module: String

    /// The name of the struct
    let name: String

    /// The type tag arguments
    let typeArgs: [TypeTag]

    public static func == (lhs: StructTagValue, rhs: StructTagValue) -> Bool {
        return
            lhs.address == rhs.address &&
            lhs.module == rhs.module &&
            lhs.name == rhs.name &&
            lhs.typeArgs == rhs.typeArgs
    }
}
