//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/5/23.
//

import Foundation

/// String Type Tag
public struct StringTag: TypeProtcol, Equatable {
    /// The value itself
    public let value: String
    
    public init(value: String) {
        self.value = value
    }

    public static func ==(lhs: StringTag, rhs: StringTag) -> Bool {
        return lhs.value == rhs.value
    }

    public func variant() -> Int {
        return TypeTag.string
    }

    public static func deserialize(from deserializer: Deserializer) throws -> StringTag {
        return try StringTag(value: Deserializer.string(deserializer))
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.value)
    }
}
