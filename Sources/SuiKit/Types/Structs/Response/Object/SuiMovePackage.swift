//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import AnyCodable

public typealias MovePackageContent = [String: AnyCodable]

public struct SuiMovePackage: Codable {
    public let disassembled: MovePackageContent
}
