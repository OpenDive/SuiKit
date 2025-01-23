//
//  ValidatorApys.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftyJSON

/// Represents a collection of `ValidatorApy` instances associated with a specific epoch.
public struct ValidatorApys: Equatable {
    /// An array containing `ValidatorApy` instances, each of which represents
    /// the Annual Percentage Yield (APY) of a specific validator.
    public var apys: [ValidatorApy]

    /// A `String` representing the epoch associated with the APYs.
    /// An epoch is a specific period in the blockchain network during which
    /// the validators’ APYs are applicable. It acts as a time reference
    /// to organize the APY data in the blockchain's timeline.
    public var epoch: String

    public init(graphql: GetValidatorsApyQuery.Data) {
        self.apys = graphql.epoch!.validatorSet!.activeValidators.nodes.map { validator in
            ValidatorApy(
                address: validator.address.address,
                apy: validator.apy != nil ? UInt64((validator.apy! / 100)) : nil
            )
        }
        self.epoch = "\(graphql.epoch!.epochId)"
    }

    public init(input: JSON) {
        self.apys = input["apys"].arrayValue.map { ValidatorApy(input: $0) }
        self.epoch = input["epoch"].stringValue
    }
}
