//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/20/23.
//

import Foundation

public struct PaginatedTransactionResponse {
    public let data: [SuiTransactionBlockResponse]
    public let hasNextPage: Bool
    public let nextCursor: String?
}
