//
//  TransferObjectsTransaction.swift
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

public struct TransferObjectsTransaction: KeyProtocol, TransactionProtocol {
    /// An array of `TransactionArgument` representing the objects to be transferred.
    public var objects: [TransactionArgument]

    /// A `TransactionArgument` representing the address to which the objects will be transferred.
    public var address: TransactionArgument

    /// Initializes a new instance of `TransferObjectsTransaction`.
    /// - Parameters:
    ///   - objects: An array of `TransactionArgument` representing the objects.
    ///   - address: A `TransactionArgument` representing the address.
    public init(
        objects: [TransactionArgument],
        address: TransactionArgument
    ) {
        self.objects = objects
        self.address = address
    }

    /// Initializes a new instance of `TransferObjectsTransaction` using a JSON object.
    /// - Parameter input: The JSON object used for initialization.
    /// - Returns: An optional instance of `TransferObjectsTransaction`.
    public init?(input: JSON) {
        let transfer = input.arrayValue
        guard let address = TransactionArgument.fromJSON(transfer[1]) else {
            return nil
        }
        self.objects = transfer[0].arrayValue.compactMap {
            TransactionArgument.fromJSON($0)
        }
        self.address = address
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(objects, Serializer._struct)
        try Serializer._struct(serializer, value: address)
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            address: try Deserializer._struct(deserializer)
        )
    }
}
