//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct MakeMoveVecTransaction: KeyProtocol {
    public let kind: SuiTransactionKindName
    public let objects: [ObjectTransactionArgument]
    public let type: String?
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: kind)
        try serializer.sequence(objects, Serializer._struct)
        if let type { try Serializer.str(serializer, type) }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MakeMoveVecTransaction {
        return MakeMoveVecTransaction(
            kind: try Deserializer._struct(deserializer),
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            type: try? Deserializer.string(deserializer)
        )
    }
}
