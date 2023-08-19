//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import AnyCodable

public typealias MovePackageContent = [String: String]

public struct SuiMovePackage: Codable, KeyProtocol {
    public let disassembled: MovePackageContent
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.map(
            disassembled,
            keyEncoder: Serializer.str,
            valueEncoder: Serializer.str
        )
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiMovePackage {
        return SuiMovePackage(
            disassembled: try deserializer.map(keyDecoder: Deserializer.string, valueDecoder: Deserializer.string)
        )
    }
}
