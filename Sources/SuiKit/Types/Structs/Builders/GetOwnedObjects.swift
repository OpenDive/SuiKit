//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation

public struct GetOwnedObjects: Codable {
    public var filter: String? = nil
    public var options: GetObject
    
    public init(filter: String? = nil, options: GetObject = GetObject()) {
        self.filter = filter
        self.options = options
    }
}
