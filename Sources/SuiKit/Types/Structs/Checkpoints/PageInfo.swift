//
//  PageInfo.swift
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

/// An object that contains information regarding the current page query from a given requests.
public struct PageInfo: Equatable {
    /// The starting point of the array within the context of the entire list of objecs.
    public var startCursor: String?

    /// The ending point of the array within the context of the entire list of objects.
    public var endCursor: String?

    /// Whether or not there is another page ahead of the current page.
    public var hasNextPage: Bool

    /// Whether or not there is another page before the current page.
    public var hasPreviousPage: Bool

    public init(graphql: GetCheckpointsQuery.Data.Checkpoints.PageInfo) {
        self.startCursor = graphql.startCursor
        self.endCursor = graphql.endCursor
        self.hasNextPage = graphql.hasNextPage
        self.hasPreviousPage = graphql.hasPreviousPage
    }

    public init(graphql: QueryEventsQuery.Data.Events.PageInfo) {
        self.startCursor = graphql.startCursor
        self.endCursor = graphql.endCursor
        self.hasNextPage = graphql.hasNextPage
        self.hasPreviousPage = graphql.hasPreviousPage
    }

    public init(graphql: GetCoinsQuery.Data.Address.Coins.PageInfo) {
        self.startCursor = nil
        self.endCursor = graphql.endCursor
        self.hasNextPage = graphql.hasNextPage
        self.hasPreviousPage = false
    }

    public init(graphql: GetOwnedObjectsQuery.Data.Address.Objects.PageInfo) {
        self.startCursor = nil
        self.endCursor = graphql.endCursor
        self.hasNextPage = graphql.hasNextPage
        self.hasPreviousPage = false
    }
}
