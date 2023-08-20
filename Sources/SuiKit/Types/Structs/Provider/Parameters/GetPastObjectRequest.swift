//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct GetPastObjectRequest: Codable {
    public var objectId: String
    public var version: String
}
