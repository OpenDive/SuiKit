//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation

public struct SuiGasData: KeyProtocol {
    public var payment: [SuiObjectRef]?
    public var owner: String?
    public var price: String?
    public var budget: String?
    
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
        if let owner { try serializer.fixedBytes(Data(owner.replacingOccurrences(of: "0x", with: "").stringToBytes())) }
        if let price, let priceUint64 = UInt64(price) {
            serializer.fixedBytes(priceUint64.toData())
        }
        if let budget, let budgetUint64 = UInt64(budget) {
            serializer.fixedBytes(budgetUint64.toData())
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiGasData {
        return SuiGasData(
            payment: try? deserializer.sequence(valueDecoder: Deserializer._struct),
            owner: try? Deserializer.string(deserializer),
            price: try? Deserializer.string(deserializer),
            budget: try? Deserializer.string(deserializer)
        )
    }
}
