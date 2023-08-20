//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct ValidatorApy {
    public var address: String
    public var apy: UInt64

    public init(input: JSON) {
        self.address = input["address"].stringValue
        self.apy = input["apy"].uInt64Value
    }
}
