//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiObjectChangePublished {
    public let type: String = "published"
    public let packageId: objectId
    public let version: SequenceNumber
    public let digest: ObjectDigest
    public let modules: [String]

    public init(input: JSON) {
        self.packageId = input["packageId"].stringValue
        self.version = input["version"].stringValue
        self.digest = input["digest"].stringValue
        self.modules = input["modules"].arrayValue.map { $0.stringValue }
    }
}
