//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct SuiObjectResponse {
    public let objectId: String
    public let version: Int
    public let digest: String
    public let type: String?
    public let owner: ObjectOwner?
    public let previousTransaction: String?
    public let storageRebate: Int?
    public let content: SuiMoveObject
}
