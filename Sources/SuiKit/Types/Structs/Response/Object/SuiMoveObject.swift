//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation
import SwiftyJSON

public struct SuiMoveObject: Codable {
    public let dataType: String
    public let type: String
    public let hasPublicTransfer: Bool
    public let fields: JSON
}
