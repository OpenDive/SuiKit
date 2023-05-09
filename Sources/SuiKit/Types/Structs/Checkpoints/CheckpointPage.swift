//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct CheckpointPage {
    public let data: [Checkpoint]
    public let nextCursor: String
    public let hasNextPage: Bool
}
