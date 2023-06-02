//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct SharedObjectRef {
    public let objectId: String
    public let initialSharedVersion: UInt8
    public let mutable: Bool
}
