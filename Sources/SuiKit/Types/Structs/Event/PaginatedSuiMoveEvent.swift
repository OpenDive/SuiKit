//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/4/23.
//

import Foundation

public struct PaginatedSuiMoveEvent {
    public let data: [SuiMoveEvent]
    public let nextCursor: Cursor
    public let hasNextPage: Bool
}

public struct Cursor {
    public let txDigest: String
    public let eventSeq: String
}
