//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/21/23.
//

import Foundation

public struct ExportedAccount {
    public let schema: KeyType
    public let privateKey: String
    
    public init(schema: KeyType, privateKey: String) {
        self.schema = schema
        self.privateKey = privateKey
    }
}
