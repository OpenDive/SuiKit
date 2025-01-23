//
//  CoinBalance.swift
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

/// Represents the balance details of a specific coin type in a user's account or wallet.
public struct CoinBalance: Equatable {
    /// A string that represents the type of coin.
    /// This could be the name or the identifier of the coin/cryptocurrency.
    public let coinType: StructTag

    /// An integer representing the count of coin objects within the specified coin type.
    /// Coin objects are instances or units of the coin type.
    public let coinObjectCount: Int

    /// A string representing the total balance of the coin type in the account or wallet.
    /// This is typically the sum of the values of all coin objects of this coin type.
    public let totalBalance: String

    /// An optional `LockedBalance` instance representing any locked balance of the coin type.
    /// Locked balance is the portion of the total balance that is restricted or not readily available for use.
    public let lockedBalance: LockedBalance?

    public init(graphql: GetBalanceQuery.Data.Address.Balance) throws {
        self.coinType = try StructTag.fromStr(graphql.coinType.repr)
        self.coinObjectCount = Int(graphql.coinObjectCount!)!
        self.totalBalance = graphql.totalBalance!
        self.lockedBalance = nil
    }

    public init(graphql: GetAllBalancesQuery.Data.Address.Balances.Node) throws {
        self.coinType = try StructTag.fromStr(graphql.coinType.repr)
        self.coinObjectCount = Int(graphql.coinObjectCount!)!
        self.totalBalance = graphql.totalBalance!
        self.lockedBalance = nil
    }

    public init(
        coinType: String,
        coinObjectCount: Int,
        totalBalance: String,
        lockedBalance: LockedBalance?
    ) throws {
        self.coinType = try StructTag.fromStr(coinType)
        self.coinObjectCount = coinObjectCount
        self.totalBalance = totalBalance
        self.lockedBalance = lockedBalance
    }
}
