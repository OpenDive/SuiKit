//
//  SuiGasData.swift
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

/// The gas data used for the transaction
public struct SuiGasData: KeyProtocol {
    /// The payment objects used for the transaction
    public var payment: [SuiObjectRef]?

    /// The owner of the transaction
    public var owner: AccountAddress?

    /// The total price of the gas used
    public var price: String?

    /// The budget set with the gas data
    public var budget: String?

    public init() {
        self.payment = nil
        self.owner = nil
        self.price = nil
        self.budget = nil
    }

    public init(
        payment: [SuiObjectRef]? = nil,
        owner: String? = nil,
        price: String? = nil,
        budget: String? = nil
    ) {
        self.payment = payment
        self.owner = owner != nil ? try? AccountAddress.fromHex(owner!) : nil
        self.price = price
        self.budget = budget
    }

    public init(
        payment: [SuiObjectRef]? = nil,
        owner: AccountAddress? = nil,
        price: String? = nil,
        budget: String? = nil
    ) {
        self.payment = payment
        self.owner = owner
        self.price = price
        self.budget = budget
    }

    public init?(input: JSON) {
        guard let owner = try? AccountAddress.fromHex(input["owner"].stringValue) else { return nil }
        self.payment = input["payment"].arrayValue.compactMap { SuiObjectRef(input: $0) }
        self.owner = owner
        self.price = input["price"].string
        self.budget = input["budget"].string
    }

    public func serialize(_ serializer: Serializer) throws {
        if let payment { try serializer.sequence(payment, Serializer._struct) }
        if let owner { try Serializer._struct(serializer, value: owner) }
        if let price, let priceUint64 = UInt64(price) {
            try Serializer.u64(serializer, priceUint64)
        }
        if let budget, let budgetUint64 = UInt64(budget) {
            try Serializer.u64(serializer, budgetUint64)
        }
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> SuiGasData {
        return SuiGasData(
            payment: (try? deserializer.sequence(valueDecoder: Deserializer._struct)) ?? [],
            owner: try? Deserializer._struct(deserializer),
            price: try? "\(Deserializer.u64(deserializer))",
            budget: try? "\(Deserializer.u64(deserializer))"
        )
    }
}
