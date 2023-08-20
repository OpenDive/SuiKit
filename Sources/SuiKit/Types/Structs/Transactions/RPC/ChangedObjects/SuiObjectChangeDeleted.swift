//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiObjectChangeDeleted {
    public let type: String = "deleted"
    public let sender: AccountAddress
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        self.sender = sender
        self.objectType = input["objectType"].stringValue
        self.objectId = input["objectId"].stringValue
        self.version = input["version"].stringValue
    }
}
