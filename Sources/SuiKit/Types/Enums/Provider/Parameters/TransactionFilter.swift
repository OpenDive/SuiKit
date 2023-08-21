//
//  TransactionFilter.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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
