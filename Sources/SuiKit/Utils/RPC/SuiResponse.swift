//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation
import SwiftyJSON

public struct SuiResponse: Codable {
    let jsonrpc: String
    let result: JSON
}
