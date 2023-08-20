//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct BalanceChange {
    public let owner: ObjectOwner
    public let coinType: String
    public let amount: String

    public init?(input: JSON) {
        guard let owner = ObjectOwner.parseJSON(input["owner"]) else { return nil }
        self.owner = owner
        self.coinType = input["coinType"].stringValue
        self.amount = input["amount"].stringValue
    }
}
