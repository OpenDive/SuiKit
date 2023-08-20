//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct TransactionEffectsModifiedAtVersions {
    public let objectId: objectId
    public let sequenceNumber: SequenceNumber

    public init(input: JSON) {
        self.objectId = input["objectId"].stringValue
        self.sequenceNumber = input["sequenceNumber"].stringValue
    }
}
