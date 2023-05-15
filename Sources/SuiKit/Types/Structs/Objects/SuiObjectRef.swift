//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation

public struct SuiObjectRef: Codable {
    public let version: UInt8
    public let objectId: objectId
    public let digest: TransactionDigest
}
