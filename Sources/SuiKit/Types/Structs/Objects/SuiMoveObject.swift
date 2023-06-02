//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation

public typealias ObjectContentFields = [String: Any]

public struct SuiMoveObject {
    public let type: String
    public let fields: ObjectContentFields
    public let hasPublicTransfer: Bool
}
