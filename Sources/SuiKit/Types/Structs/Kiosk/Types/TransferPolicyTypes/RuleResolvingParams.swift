//
//  RuleResolvingParams.swift
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
import AnyCodable

/// The object a Rule resolving function accepts
/// It can accept a set of fixed fields, that are part of every purchase flow as well any extra arguments to resolve custom policies!
/// Each rule resolving function should check that the key it's seeking is in the object
/// e.g. `if(!'my_key' in ruleParams!) throw new Error("Can't resolve that rule!")`
public struct RuleResolvingParams {
    public let itemType: String
    public let itemId: String
    public let price: String
    public let policyId: ObjectArgument
    public let sellerKiosk: ObjectArgument
    public let kiosk: ObjectArgument
    public let kioskCap: ObjectArgument
    public let transferRequest: TransactionObjectArgument
    public let purchasedItem: TransactionObjectArgument
    public let packageId: String
    public let extraArgs: [String: AnyCodable]
}
