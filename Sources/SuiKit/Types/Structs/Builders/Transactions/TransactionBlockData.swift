//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/13/23.
//

import Foundation
import BigInt

public struct TransactionBlockDataBuilder {
    public var serializedTransactionDataBuilder: SerializedTransactionDataBuilder
    
    public static func fromKindBytes(bytes: Data) {
        
    }
    
    public static func restore(data: SerializedTransactionDataBuilder) -> TransactionBlockDataBuilder {
        return TransactionBlockDataBuilder(serializedTransactionDataBuilder: data)
    }
}

public let TRANSACTION_DATA_MAX_SIZE = 128 * 1024

public func prepareSuiAddress(address: String) -> String {
    return normalizeSuiAddress(value: address).replacingOccurrences(of: "0x", with: "")
}

public struct SerializedTransactionDataBuilder {
    public let version: UInt8 = 1
    public let sender: SuiAddress?
    public let expiration: TransactionExpiration
    public let gasConfig: GasConfig
    public let inputs: [TransactionBlockInput]
    public let transactions: [any TransactionTypesProtocol]
}

public struct GasConfig {
    public let budget: StringEncodedBigInt?
    public let price: StringEncodedBigInt?
    public let paynment: StringEncodedBigInt?
    public let owner: SuiAddress?
}

public enum TransactionExpiration {
    case epoch(Int)
    case none
}

extension TransactionExpiration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else {
            let value = try container.decode(Int.self)
            self = .epoch(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .epoch(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
        }
    }
}

public struct StringEncodedBigInt {
    public let value: BigInt

    public init?(from value: Any) {
        switch value {
        case let string as String:
            guard let bigInt = BigInt(string) else { return nil }
            self.value = bigInt
        case let int as Int:
            self.value = BigInt(int)
        case let bigInt as BigInt:
            self.value = bigInt
        default:
            return nil
        }
    }
}
