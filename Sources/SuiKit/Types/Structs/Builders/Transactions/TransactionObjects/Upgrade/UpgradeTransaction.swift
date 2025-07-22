//
//  UpgradeTransaction.swift
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

public struct UpgradeTransaction: KeyProtocol, TransactionProtocol {
    /// Represents a set of modules where each module is an array of UInt8.
    public let modules: [[UInt8]]

    /// An array of object IDs representing dependencies.
    public let dependencies: [ObjectId]

    /// The ID of the package.
    public let packageId: ObjectId

    /// Represents a ticket which is an instance of `TransactionArgument`.
    public let ticket: TransactionArgument

    /// Initializes a new instance of `UpgradeTransaction`.
    /// - Parameters:
    ///   - modules: Represents a set of modules.
    ///   - dependencies: An array of object IDs representing dependencies.
    ///   - packageId: The ID of the package.
    ///   - ticket: Represents a ticket which is an instance of `TransactionArgument`.
    public init(
        modules: [[UInt8]],
        dependencies: [ObjectId],
        packageId: ObjectId,
        ticket: TransactionArgument
    ) {
        self.modules = modules
        self.dependencies = dependencies
        self.packageId = packageId
        self.ticket = ticket
    }

    /// Initializes a new instance of `UpgradeTransaction` using a JSON object.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `UpgradeTransaction`.
    public init?(input: JSON) {
        let upgrade = input.arrayValue
        guard let ticket = TransactionArgument.fromJSON(upgrade[3]) else { return nil }
        self.modules = upgrade[0].arrayValue.map { $0.arrayValue.map { $0.uInt8Value } }
        self.dependencies = upgrade[1].arrayValue.map { $0.stringValue }
        self.packageId = upgrade[2].stringValue
        self.ticket = ticket
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(self.modules.map { Data($0) }, Serializer.toBytes)
        try serializer.sequence(self.dependencies, Serializer.str)
        try Serializer.str(serializer, self.packageId)
        try Serializer._struct(serializer, value: self.ticket)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> UpgradeTransaction {
        return UpgradeTransaction(
            modules: (try deserializer.sequence(valueDecoder: Deserializer.toBytes)).map { [UInt8]($0) },
            dependencies: try deserializer.sequence(valueDecoder: Deserializer.string),
            packageId: try Deserializer.string(deserializer),
            ticket: try Deserializer._struct(deserializer)
        )
    }
}
