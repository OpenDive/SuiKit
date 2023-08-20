//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct OwnedObjectRef {
    public let owner: ObjectOwner
    public let reference: SuiObjectRef

    public init?(input: JSON) {
        guard let owner = ObjectOwner.parseJSON(input["owner"]) else { return nil }
        self.owner = owner
        self.reference = SuiObjectRef(input: input["reference"])
    }
}
