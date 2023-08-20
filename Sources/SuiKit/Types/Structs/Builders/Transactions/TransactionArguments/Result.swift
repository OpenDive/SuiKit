//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct Result: KeyProtocol {
    public let index: UInt16
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, index)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Result {
        return Result(
            index: try Deserializer.u16(deserializer)
        )
    }
}
