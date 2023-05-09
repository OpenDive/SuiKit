//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct SuiObjectOwner: Codable {
    enum CodingKeys: String, CodingKey {
        case addressOwner = "AddressOwner"
    }
    public let addressOwner: String
}
