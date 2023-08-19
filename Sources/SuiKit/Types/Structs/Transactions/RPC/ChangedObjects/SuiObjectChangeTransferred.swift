//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiObjectChangeTransferred {
    public let type: String = "transferred"
    public let sender: AccountAddress
    public let recipient: ObjectOwner
    public let objectType: String
    public let objectId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        guard let recipient = ObjectOwner.parseJSON(input["recipient"]) else { return nil }
        self.sender = sender
        self.recipient = recipient
        self.objectType = input["objectType"].stringValue
        self.objectId = input["objectId"].stringValue
        self.version = input["version"].stringValue
        self.digest = input["digest"].stringValue
    }
}
