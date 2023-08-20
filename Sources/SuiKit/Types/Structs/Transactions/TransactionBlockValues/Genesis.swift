//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct Genesis: KeyProtocol {
    public let objects: [objectId]

    public init(objects: [objectId]) {
        self.objects = objects
    }

    public init(input: JSON) {
        self.objects = input.arrayValue.map { $0.stringValue }
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(objects, Serializer.str)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Genesis {
        return Genesis(objects: try deserializer.sequence(valueDecoder: Deserializer.string))
    }
}
