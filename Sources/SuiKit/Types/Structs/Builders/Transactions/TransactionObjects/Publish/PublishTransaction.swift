//
//  PublishTransaction.swift
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

public struct PublishTransaction: KeyProtocol, TransactionProtocol {
    /// An array of modules where each module is represented as an array of `UInt8`.
    public let modules: [[UInt8]]

    /// An array of dependencies represented by `AccountAddress`.
    public let dependencies: [AccountAddress]

    /// Initializes a new instance of `PublishTransaction`.
    /// - Parameters:
    ///   - modules: An array of modules where each module is represented as an array of `UInt8`.
    ///   - dependencies: An array of dependencies represented by `objectId`.
    /// - Throws: If conversion of objectId to AccountAddress fails.
    public init(modules: [[UInt8]], dependencies: [ObjectId]) throws {
        self.modules = modules
        self.dependencies = try dependencies.map { try AccountAddress.fromHex($0) }
    }

    /// Initializes a new instance of `PublishTransaction` using a JSON object.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `PublishTransaction`.
    public init?(input: JSON) {
        let publish = input.arrayValue
        self.modules = publish[0].arrayValue.map {
            $0.arrayValue.map { $0.uInt8Value }
        }
        self.dependencies = publish[1].arrayValue.compactMap {
            try? AccountAddress.fromHex($0.stringValue)
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(modules.map { Data($0) }, Serializer.toBytes)
        try serializer.uleb128(UInt(self.dependencies.count))  // TODO: Check if we need it as this or if we can use it as a sequence.
        for dependency in dependencies {
            try Serializer._struct(serializer, value: dependency)
        }
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> PublishTransaction {
        return try PublishTransaction(
            modules: (try deserializer.sequence(valueDecoder: Deserializer.toBytes)).map {
                [UInt8]($0)
            },
            dependencies: try deserializer.sequence(valueDecoder: Deserializer.string)
        )
    }
}
