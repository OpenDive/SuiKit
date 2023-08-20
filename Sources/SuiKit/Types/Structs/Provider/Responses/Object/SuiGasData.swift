//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import SwiftyJSON

public struct SuiGasData: KeyProtocol {
    public var payment: [SuiObjectRef]?
    public var owner: AccountAddress?
    public var price: String?
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

    public static func deserialize(from deserializer: Deserializer) throws -> SuiGasData {
        return SuiGasData(
            payment: (try? deserializer.sequence(valueDecoder: Deserializer._struct)) ?? [],
            owner: try? Deserializer._struct(deserializer),
            price: try? "\(Deserializer.u64(deserializer))",
            budget: try? "\(Deserializer.u64(deserializer))"
        )
    }
}
