//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation
import SwiftyJSON

public struct SuiMoveObject: Codable {
    let dataType: String
    let type: String
    let hasPublicTransfer: Bool
    let fields: JSON
}
