//
//  PaginatedCoins.swift
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

/// Represents a paginated set of `CoinStruct`, often used to handle large sets of coins
/// and retrieve them page by page to minimize load and optimize performance.
public struct PaginatedCoins: Equatable {
    /// An array of `CoinStruct` representing the coin structures contained in the current page.
    public let data: [CoinStruct]

    /// A string representing the object identifier (objectId) for the next cursor in the pagination.
    /// It is used to retrieve the next page of `CoinStruct` objects.
    public let nextCursor: ObjectId?

    /// The object corresponding to the information of the current coin page.
    public let pageInfo: PageInfo?

    /// A boolean value indicating whether there is a next page available in the pagination.
    public let hasNextPage: Bool?

    public init(
        data: [CoinStruct],
        nextCursor: ObjectId? = nil,
        pageInfo: PageInfo? = nil,
        hasNextPage: Bool? = nil
    ) {
        self.data = data
        self.nextCursor = nextCursor
        self.pageInfo = pageInfo
        self.hasNextPage = hasNextPage
    }
}
