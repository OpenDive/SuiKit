//
//  TransferPolicy.swift
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

/// The `TransferPolicy` object
public struct TransferPolicy: KeyProtocol {
    public let id: AccountAddress
    public let type: String?
    public let balance: UInt64
    public let rules: [String]
    public let owner: ObjectOwner?

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.id)
        if let type = self.type { try Serializer.str(serializer, type) }
        try Serializer.u64(serializer, self.balance)
        try serializer.sequence(self.rules, Serializer.str)
        if let owner = self.owner { try Serializer._struct(serializer, value: owner) }

    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransferPolicy {
        return TransferPolicy(
            id: try AccountAddress.deserialize(from: deserializer),
            type: nil,
            balance: try Deserializer.u64(deserializer),
            rules: try deserializer.sequence(valueDecoder: Deserializer.string),
            owner: nil
        )
    }
}
