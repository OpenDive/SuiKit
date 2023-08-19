//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct TransactionDataV1: KeyProtocol {
    public let kind: SuiTransactionBlockKind
    public let sender: AccountAddress
    public let gasData: SuiGasData
    public let expiration: TransactionExpiration

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.kind)
        try Serializer._struct(serializer, value: self.sender)
        try Serializer._struct(serializer, value: self.gasData)
        try Serializer._struct(serializer, value: self.expiration)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionDataV1 {
        return TransactionDataV1(
            kind: try Deserializer._struct(deserializer),
            sender: try Deserializer._struct(deserializer),
            gasData: try Deserializer._struct(deserializer),
            expiration: try Deserializer._struct(deserializer)
        )
    }
}
