//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct UpgradeTransaction: KeyProtocol, TransactionProtocol {
    public let modules: [[UInt8]]
    public let dependencies: [objectId]
    public let packageId: objectId
    public let ticket: TransactionArgument

    public init(
        modules: [[UInt8]],
        dependencies: [objectId],
        packageId: objectId,
        ticket: TransactionArgument
    ) {
        self.modules = modules
        self.dependencies = dependencies
        self.packageId = packageId
        self.ticket = ticket
    }

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

    public static func deserialize(from deserializer: Deserializer) throws -> UpgradeTransaction {
        return UpgradeTransaction(
            modules: (try deserializer.sequence(valueDecoder: Deserializer.toBytes)).map { [UInt8]($0) },
            dependencies: try deserializer.sequence(valueDecoder: Deserializer.string),
            packageId: try Deserializer.string(deserializer),
            ticket: try Deserializer._struct(deserializer)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try ticket.encodeInput(objects: &objects, inputs: &inputs)
    }
}
