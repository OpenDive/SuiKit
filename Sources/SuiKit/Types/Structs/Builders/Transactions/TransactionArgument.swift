//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable

public enum TransactionArgument: Codable {
    case transactionBlockInput(TransactionBlockInput)
    case gasCoin(GasCoin)
    case result(Result)
    case nestedResult(NestedResult)
    
    private enum CodingKeys: CodingKey {
        case transactionBlockInput
        case gasCoin
        case result
        case nestedResult
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(TransactionBlockInput.self, forKey: .transactionBlockInput) {
            self = .transactionBlockInput(value)
        } else if let value = try? container.decode(GasCoin.self, forKey: .gasCoin) {
            self = .gasCoin(value)
        } else if let value = try? container.decode(Result.self, forKey: .result) {
            self = .result(value)
        } else if let value = try? container.decode(NestedResult.self, forKey: .nestedResult) {
            self = .nestedResult(value)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode enums."))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .transactionBlockInput(let value):
            try container.encode(value, forKey: .transactionBlockInput)
        case .gasCoin(let value):
            try container.encode(value, forKey: .gasCoin)
        case .result(let value):
            try container.encode(value, forKey: .result)
        case .nestedResult(let value):
            try container.encode(value, forKey: .nestedResult)
        }
    }
}

public struct TransactionBlockInput: Codable, TransactionArgumentTypeProtocol {
    public let kind: String
    public let index: Int
    public let value: AnyCodable?
    public let valueType: ValueType?
    
    public enum CodingKeys: String, CodingKey {
        case kind
        case index
        case value
        case valueType = "type"
    }
}

public enum ValueType: String, Codable {
    case pure
    case object
}

public struct GasCoin: Codable, TransactionArgumentTypeProtocol {
    public let kind: String
}

public struct Result: Codable, TransactionArgumentTypeProtocol {
    public let kind: String
    public let index: Int
}

public struct NestedResult: Codable, TransactionArgumentTypeProtocol {
    public let kind: String
    public let index: Int
    public let resultIndex: Int
}

public struct ObjectTransactionArgument {
    public let argument: TransactionArgument
    public let kind: TransactionArgumentKind
    
    public init(argument: TransactionArgument) {
        self.argument = argument
        self.kind = .object
    }
}

public struct PureTransactionArgument {
    public let argument: TransactionArgument
    public let kind: TransactionArgumentKind
    
    public init(argument: TransactionArgument, type: String) {
        self.argument = argument
        self.kind = .pure(type: type)
    }
}
