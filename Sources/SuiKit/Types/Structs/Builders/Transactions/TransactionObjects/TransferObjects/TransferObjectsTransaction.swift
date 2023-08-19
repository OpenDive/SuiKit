//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct TransferObjectsTransaction: KeyProtocol, TransactionProtocol {
    public var objects: [TransactionArgument]
    public var address: TransactionArgument

    public init(objects: [TransactionArgument], address: TransactionArgument) {
        self.objects = objects
        self.address = address
    }

    public init?(input: JSON) {
        let transfer = input.arrayValue
        guard let address = TransactionArgument.fromJSON(transfer[1]) else { return nil }
        self.objects = transfer[0].arrayValue.compactMap { TransactionArgument.fromJSON($0) }
        self.address = address
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(objects, Serializer._struct)
        try Serializer._struct(serializer, value: address)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransferObjectsTransaction {
        return TransferObjectsTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            address: try Deserializer._struct(deserializer)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try self.objects.forEach { argument in
            try argument.encodeInput(objects: &objects, inputs: &inputs)
        }
        try self.address.encodeInput(objects: &objects, inputs: &inputs)
    }
}
