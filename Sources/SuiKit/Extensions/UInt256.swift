//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation
import UInt256

extension UInt256: Codable {
    private enum CodingKeys : String, CodingKey {
        case parts = "parts"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parts = try container.decode(String.self, forKey: .parts)
        self.init(parts)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(self)", forKey: .parts)
    }
}
