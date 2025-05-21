//
//  TransactionExpiration.swift
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

/// Represents the expiration options for a transaction.
public enum TransactionExpiration: KeyProtocol {
    /// No expiration for the transaction.
    case none

    /// Expiration time set as an epoch timestamp.
    case epoch(UInt64)

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .none:
            try Serializer.u8(serializer, UInt8(0))
        case .epoch(let int):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer.u64(serializer, UInt64(int))
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionExpiration {
        let type = try Deserializer.u8(deserializer)

        switch type {
        case 0:
            return TransactionExpiration.none
        case 1:
            return TransactionExpiration.epoch(
                try Deserializer.u64(deserializer)
            )
        default:
            throw SuiError.customError(message: "Unable to Deserialize")
        }
    }
}
