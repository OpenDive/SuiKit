//
//  SuiMoveNormalizedStructType.swift
//  SuiKit
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
import SwiftyJSON

public struct SuiMoveNormalizedStructType: Equatable, KeyProtocol, CustomStringConvertible {
    public let address: AccountAddress
    public let module: String
    public let name: String
    public let typeArguments: [SuiMoveNormalizedType]

    public var description: String {
        "\(self.address.hex())::\(self.module)::\(self.name)"
    }

    public func isSameStruct(_ rhs: any ResolvedProtocol) -> Bool {
        guard let rhsAddress = try? Inputs.normalizeSuiAddress(
            value: rhs.address
        ) else { return false }
        return
            self.address.hex() == rhsAddress &&
            self.module == rhs.module &&
            self.name == rhs.name
    }

    public init(
        address: AccountAddress,
        module: String,
        name: String,
        typeArguments: [SuiMoveNormalizedType]
    ) {
        self.address = address
        self.module = module
        self.name = name
        self.typeArguments = typeArguments
    }

    public init(input: String) throws {
        let typeTag = try StructTag.fromStr(input)
        self.address = typeTag.value.address
        self.module = typeTag.value.module
        self.name = typeTag.value.name
        self.typeArguments = []
    }

    public init?(input: JSON) {
        guard let address = try? AccountAddress.fromHex(
            input["address"].stringValue
        ) else { return nil }

        self.address = address
        self.module = input["module"].stringValue
        self.name = input["name"].stringValue
        self.typeArguments = input["arguments"].arrayValue.compactMap {
            SuiMoveNormalizedType.parseJSON($0)
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.address)
        try Serializer.str(serializer, self.module)
        try Serializer.str(serializer, self.name)
        if !self.typeArguments.isEmpty {
            try serializer.sequence(
                self.typeArguments,
                Serializer._struct
            )
        }
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> SuiMoveNormalizedStructType {
        return SuiMoveNormalizedStructType(
            address: try Deserializer._struct(deserializer),
            module: try Deserializer.string(deserializer),
            name: try Deserializer.string(deserializer),
            typeArguments: []
        )
    }
}
