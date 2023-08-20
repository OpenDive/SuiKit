//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiTransactionBlockData: KeyProtocol {
    public let messageVersion: String
    public let transaction: SuiTransactionBlockKind
    public let sender: AccountAddress
    public let gasData: SuiGasData

    public init(
        messageVersion: String,
        transaction: SuiTransactionBlockKind,
        sender: AccountAddress,
        gasData: SuiGasData
    ) {
        self.messageVersion = messageVersion
        self.transaction = transaction
        self.sender = sender
        self.gasData = gasData
    }

    public init?(input: JSON) {
        guard let transaction = SuiTransactionBlockKind.fromJSON(input["transaction"]) else { return nil }
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        guard let gasData = SuiGasData(input: input["gasData"]) else { return nil }
        self.messageVersion = input["messageVersion"].stringValue
        self.transaction = transaction
        self.sender = sender
        self.gasData = gasData
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.messageVersion)
        try Serializer._struct(serializer, value: self.transaction)
        try Serializer._struct(serializer, value: self.sender)
        try Serializer._struct(serializer, value: self.gasData)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiTransactionBlockData {
        return SuiTransactionBlockData(
            messageVersion: try Deserializer.string(deserializer),
            transaction: try Deserializer._struct(deserializer),
            sender: try Deserializer._struct(deserializer),
            gasData: try Deserializer._struct(deserializer)
        )
    }
}
