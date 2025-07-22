//
//  FaucetCoinInfo.swift
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

#if swift(>=6.0)
/// Represents information about a coin from a faucet in the Sui ecosystem.
public struct FaucetCoinInfo: Codable, Sendable {
    /// Represents the amount of coins.
    public let amount: Int

    /// The identifier of the object.
    public let id: ObjectId

    /// A `TransactionDigest` representing the transaction digest of the transfer.
    public let transferTxDigest: TransactionDigest
}
#elseif swift(<6.0)
/// Represents information about a coin from a faucet in the Sui ecosystem.
public struct FaucetCoinInfo: Codable {
    /// Represents the amount of coins.
    public let amount: Int

    /// The identifier of the object.
    public let id: ObjectId

    /// A `TransactionDigest` representing the transaction digest of the transfer.
    public let transferTxDigest: TransactionDigest
}
#endif

public struct FaucetCoins: Codable {
    /// Represents the coins (0x2::sui::SUI) that were fauceted to the account. Can be null if faucet failed
    public let coinsSent: [FaucetCoinInfo]?

    /// Represents either "success" if the faucet succeeded, or a "Failure" object with `status` string containing a `JSON` object.
    public let status: String

    enum CodingKeys: String, CodingKey {
        case coinsSent = "coins_sent"
        case status
    }
}
