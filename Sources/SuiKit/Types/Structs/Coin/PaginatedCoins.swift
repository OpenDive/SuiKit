//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct PaginatedCoins {
    public let data: [CoinStruct]
    public let nextCursor: objectId
    public let hasNextPage: Bool
}
