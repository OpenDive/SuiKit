//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/4/23.
//

import Foundation

public struct PaginatedSuiMoveEvent {
    public let data: [SuiEvent]
    public let nextCursor: EventId
    public let hasNextPage: Bool
}

public struct Cursor {
    public let txDigest: String
    public let eventSeq: String
}
