//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct PaginatedObjectsResponse {
    public var data: [SuiObjectResponse]
    public var hasNextPage: Bool
    public var nextCursor: String?
}
