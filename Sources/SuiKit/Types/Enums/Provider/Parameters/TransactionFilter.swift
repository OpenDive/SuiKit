//
//  TransactionFilter.swift
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

/// `TransactionFilter` enumerates the various filters that can be applied when querying transactions.
///
/// This enum allows for precise filtering based on different transaction attributes such as the involved
/// addresses, checkpoint, transaction kind, etc.
public enum TransactionFilter: Codable {
    /// Keys used for encoding and decoding the enum cases.
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

    /// Filter transactions that match a given checkpoint.
    case checkpoint(String)

    /// Filter transactions that involve a specific Move function.
    case moveFunction(TransactionMoveFunction)

    /// Filter transactions that include a specific input object.
    case inputObject(String)

    /// Filter transactions that changed a specific object.
    case changedObject(String)

    /// Filter transactions that originated from a specific address.
    case fromAddress(String)

    /// Filter transactions that are destined for a specific address.
    case toAddress(String)

    /// Filter transactions involving both a specific 'from' and 'to' address.
    case fromAndToAddress(FromAndToAddress)

    /// Filter transactions involving either a specific 'from' or 'to' address.
    case fromOrToAddress(FromOrToAddress)

    /// Filter transactions of a specific kind.
    case transactionKind(String)

    /// Filter transactions belonging to any of a list of kinds.
    case transactionKindIn([String])

    /// Encode the enum into a container.
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
