//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct SuiObjectInfo {
    public let suiObjectRef: SuiObjectRef
    public let type: String
    public let owner: ObjectOwner
    public let previousTransaction: TransactionDigest
}
