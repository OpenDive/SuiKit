//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation

public struct SuiGasData: KeyProtocol {
    public let payment: [SuiObjectRef]?
    public let owner: String?
    public let price: String?
    public let budget: String?
    
    public init(
        payment: [SuiObjectRef]? = nil,
        owner: String? = nil,
        price: String? = nil,
        budget: String? = nil
    ) {
        self.payment = payment
        self.owner = owner
        self.price = price
        self.budget = budget
    }
    
    public func serialize(_ serializer: Serializer) throws {
        if let payment { try serializer.sequence(payment, Serializer._struct) }
        if let owner { try Serializer.str(serializer, owner) }
        if let price { try Serializer.str(serializer, price) }
        if let budget { try Serializer.str(serializer, budget) }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiGasData {
        return SuiGasData(
            payment: try deserializer.sequence(valueDecoder: Deserializer._struct),
            owner: try Deserializer.string(deserializer),
            price: try Deserializer.string(deserializer),
            budget: try Deserializer.string(deserializer)
        )
    }
}
