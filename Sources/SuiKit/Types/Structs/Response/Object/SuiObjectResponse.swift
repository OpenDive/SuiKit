//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct SuiObjectResponse {
    let objectId: String
    let version: Int
    let digest: String
    let type: String?
    let owner: SuiObjectOwner?
    let previousTransaction: String?
    let storageRebate: Int?
    let content: SuiMoveObject
}
