//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import AnyCodable

public struct MoveEventField: Codable {
    public var path: String
    public var value: AnyCodable
}
