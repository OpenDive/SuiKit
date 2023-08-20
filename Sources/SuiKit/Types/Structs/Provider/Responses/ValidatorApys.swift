//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct ValidatorApys {
    public var apys: [ValidatorApy]
    public var epoch: String

    public init(input: JSON) {
        self.apys = input["apys"].arrayValue.map { ValidatorApy(input: $0) }
        self.epoch = input["epoch"].stringValue
    }
}
