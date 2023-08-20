//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct MakeMoveVecTransaction: KeyProtocol, TransactionProtocol {
    public let objects: [TransactionArgument]
    public let type: String?

    public init(objects: [TransactionArgument], type: String?) {
        self.objects = objects
        self.type = type
    }

    public init?(input: JSON) {
        let vec = input.arrayValue
        self.objects = vec[0].arrayValue.compactMap { TransactionArgument.fromJSON($0) }
        self.type = vec[1].string
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(0)
        try serializer.sequence(objects, Serializer._struct)
        if let type { try Serializer.str(serializer, type) }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MakeMoveVecTransaction {
        let _ = Deserializer.uleb128(deserializer)
        return MakeMoveVecTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            type: try? Deserializer.string(deserializer)
        )
    }

    public func executeTransaction(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        try self.objects.forEach { argument in
            try argument.encodeInput(objects: &objects, inputs: &inputs)
        }
    }
}
