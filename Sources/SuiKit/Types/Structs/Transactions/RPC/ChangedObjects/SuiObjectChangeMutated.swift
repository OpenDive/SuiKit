//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiObjectChangeMutated {
    public let type: String = "mutated"
    public let sender: AccountAddress
    public let owner: ObjectOwner
    public let objectType: String
    public let version: SequenceNumber
    public let previousVersion: SequenceNumber
    public let digest: ObjectDigest

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        guard let owner = ObjectOwner.parseJSON(input["owner"]) else { return nil }
        self.sender = sender
        self.owner = owner
        self.objectType = input["objectType"].stringValue
        self.version = input["version"].stringValue
        self.previousVersion = input["previousVersion"].stringValue
        self.digest = input["digest"].stringValue
    }
}
