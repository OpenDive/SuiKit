//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct DynamicFieldPage {
    public var data: [DynamicFieldInfo]
    public var nextCursor: String?
    public var hasNextPage: Bool
}
