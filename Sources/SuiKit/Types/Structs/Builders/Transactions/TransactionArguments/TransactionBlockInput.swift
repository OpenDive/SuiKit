//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct TransactionBlockInput: KeyProtocol {
    public var index: UInt16
    public var value: SuiJsonValue?
    public var type: ValueType?

    public init(
        index: UInt16,
        value: SuiJsonValue? = nil,
        type: ValueType? = nil
    ) {
        self.index = index
        self.value = value
        self.type = type
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionBlockInput {
        return TransactionBlockInput(
            index: try Deserializer.u16(deserializer)
        )
    }
}
