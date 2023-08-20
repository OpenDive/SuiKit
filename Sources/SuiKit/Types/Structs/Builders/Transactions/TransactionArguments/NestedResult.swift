//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct NestedResult: KeyProtocol {
    public let index: UInt16
    public let resultIndex: UInt16
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
        try Serializer.u16(serializer, resultIndex)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> NestedResult {
        return NestedResult(
            index: try Deserializer.u16(deserializer),
            resultIndex: try Deserializer.u16(deserializer)
        )
    }
}
