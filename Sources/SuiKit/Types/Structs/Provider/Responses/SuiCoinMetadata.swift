//
//  SuiCoinMetadata.swift
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

/// Represents metadata associated with a SuiCoin, providing details and information
/// related to a specific coin in the system.
public struct SuiCoinMetadata: Equatable {
    /// An `UInt8` value representing the number of decimals to which the coin can be divided.
    /// This attribute is useful for representing fractional values of the coin.
    let decimals: UInt8

    /// A `String` providing a human-readable description of the coin, explaining its purpose,
    /// usage, or any other relevant information that helps in understanding the coin's context.
    let description: String

    /// An optional `String` containing the URL of the coin's icon. This URL can be used to
    /// retrieve the visual representation or logo associated with the coin.
    let iconUrl: String?

    /// A `String` representing the name of the coin. This is typically a full or formal name
    /// that is used to refer to the coin in official or detailed contexts.
    let name: String

    /// A `String` representing the symbol of the coin. This is usually a short, concise representation
    /// used for quick reference or display, such as in trading pairs or price listings.
    let symbol: String

    /// A `String` serving as a unique identifier for the coin, allowing for differentiation and
    /// reference to this specific coin instance within the system.
    let id: String

    public init(graphql: GetCoinMetadataQuery.Data.CoinMetadata) {
        self.decimals = UInt8(graphql.decimals!)
        self.name = graphql.name!
        self.symbol = graphql.symbol!
        self.description = graphql.description!
        self.iconUrl = graphql.iconUrl
        self.id = graphql.address
    }

    public init(decimals: UInt8, description: String, iconUrl: String?, name: String, symbol: String, id: String) {
        self.decimals = decimals
        self.description = description
        self.iconUrl = iconUrl
        self.name = name
        self.symbol = symbol
        self.id = id
    }
}
