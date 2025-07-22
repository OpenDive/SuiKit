//
//  PaginatedSuiMoveEvent.swift
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

/// Represents a paginated list of Sui Move Events.
public struct PaginatedSuiMoveEvent {
    /// An array of `SuiEvent` objects representing the events in the current page.
    public let data: [SuiEvent]

    /// An `EventId` object representing the cursor to the next page of events.
    public let nextCursor: EventId?

    public let pageInfo: PageInfo?

    /// A Boolean value indicating whether there is a next page of events available.
    public let hasNextPage: Bool?

    public init(data: [SuiEvent], nextCursor: EventId? = nil, pageInfo: PageInfo? = nil, hasNextPage: Bool? = nil) {
        self.data = data
        self.nextCursor = nextCursor
        self.pageInfo = pageInfo
        self.hasNextPage = hasNextPage
    }
}
