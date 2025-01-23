//
//  PaginatedObjectsResponse.swift
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

/// Represents a paginated response containing a list of `SuiObjectResponse` instances,
/// which may represent objects retrieved from the Sui blockchain, along with
/// pagination information.
public struct PaginatedObjectsResponse {
    /// An array of `SuiObjectResponse` instances, each representing the response
    /// for a specific object, possibly containing object data or errors.
    public var data: [SuiObjectResponse]

    /// A Boolean value indicating whether there are more pages of objects available to be retrieved.
    /// `true` if there are more pages available, otherwise `false`.
    public var hasNextPage: Bool?

    /// An optional string representing the cursor for the next page of objects.
    /// `nil` if there are no more pages available.
    public var nextCursor: String?

    /// Page info object for the given Object Response page.
    public var pageInfo: PageInfo?

    public init(data: [SuiObjectResponse], pageInfo: PageInfo? = nil, hasNextPage: Bool? = nil, nextCursor: String? = nil) {
        self.data = data
        self.hasNextPage = hasNextPage
        self.nextCursor = nextCursor
        self.pageInfo = pageInfo
    }
}
