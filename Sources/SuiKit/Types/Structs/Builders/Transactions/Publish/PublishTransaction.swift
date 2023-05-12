//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct PublishTransaction {
    public let kind: String
    public let modules: [[UInt8]]
    public let dependencies: [objectId]
}
