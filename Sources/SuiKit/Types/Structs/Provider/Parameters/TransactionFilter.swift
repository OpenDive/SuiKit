//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/20/23.
//

import Foundation

public enum TransactionFilter: Codable {
    private enum CodingKeys: String, CodingKey {
        case checkpoint = "Checkpoint"
        case moveFunction = "MoveFunction"
        case inputObject = "InputObject"
        case changedObject = "ChangedObject"
        case fromAddress = "FromAddress"
        case toAddress = "ToAddress"
        case fromAndToAddress = "FromAndToAddress"
        case fromOrToAddress = "FromOrToAddress"
        case transactionKind = "TransactionKind"
        case transactionKindIn = "TransactionKindIn"
    }

    case checkpoint(String)
    case moveFunction(TransactionMoveFunction)
    case inputObject(String)
    case changedObject(String)
    case fromAddress(String)
    case toAddress(String)
    case fromAndToAddress(FromAndToAddress)
    case fromOrToAddress(FromOrToAddress)
    case transactionKind(String)
    case transactionKindIn([String])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .checkpoint(let string):
            try container.encode(string, forKey: .checkpoint)
        case .moveFunction(let transactionMoveFunction):
            try container.encode(transactionMoveFunction, forKey: .moveFunction)
        case .inputObject(let string):
            try container.encode(string, forKey: .inputObject)
        case .changedObject(let string):
            try container.encode(string, forKey: .changedObject)
        case .fromAddress(let string):
            try container.encode(string, forKey: .fromAddress)
        case .toAddress(let string):
            try container.encode(string, forKey: .toAddress)
        case .fromAndToAddress(let fromAndToAddress):
            try container.encode(fromAndToAddress, forKey: .fromAndToAddress)
        case .fromOrToAddress(let fromOrToAddress):
            try container.encode(fromOrToAddress, forKey: .fromOrToAddress)
        case .transactionKind(let string):
            try container.encode(string, forKey: .transactionKind)
        case .transactionKindIn(let array):
            try container.encode(array, forKey: .transactionKindIn)
        }
    }
}
