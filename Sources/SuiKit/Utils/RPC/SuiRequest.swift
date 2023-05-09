//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation
import SwiftyJSON
import AnyCodable

public struct SuiRequest: Codable {
    var id: Int = Int(arc4random())
    var method: String = ""
    var jsonrpc: String = "2.0"
    var params: [AnyCodable]
    
    public init(_ method: String, _ params: [AnyCodable]) {
        self.method = method
        self.params = params
    }
}
