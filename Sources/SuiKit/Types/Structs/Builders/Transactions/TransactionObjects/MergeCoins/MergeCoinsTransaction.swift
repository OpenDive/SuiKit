//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct MergeCoinsTransaction: KeyProtocol, TransactionProtocol {
    public let destination: TransactionArgument
    public let sources: [TransactionArgument]

    public init(destination: TransactionArgument, sources: [TransactionArgument]) {
        self.destination = destination
        self.sources = sources
    }

    public init?(input: JSON) {
        let merge = input.arrayValue
        guard let destination = TransactionArgument.fromJSON(merge[0]) else { return nil }
        self.destination = destination
        self.sources = merge[1].arrayValue.compactMap { TransactionArgument.fromJSON($0) }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: destination)
        try serializer.sequence(sources, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MergeCoinsTransaction {
        return MergeCoinsTransaction(
            destination: try Deserializer._struct(deserializer),
            sources: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try destination.encodeInput(objects: &objects, inputs: &inputs)

        try sources.forEach { argument in
            try argument.encodeInput(objects: &objects, inputs: &inputs)
        }
    }
}
