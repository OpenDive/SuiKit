//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct SplitCoinsTransaction: KeyProtocol, Codable {
    public let kind: String
    public let coin: ObjectTransactionArgument
    public let amounts: [PureTransactionArgument]
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, kind)
        try Serializer._struct(serializer, value: coin)
        try serializer.sequence(amounts, Serializer._struct)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SplitCoinsTransaction {
        return SplitCoinsTransaction(
            kind: try Deserializer.string(deserializer),
            coin: try Deserializer._struct(deserializer),
            amounts: try deserializer.sequence(valueDecoder: Deserializer._struct)
        )
    }
}
