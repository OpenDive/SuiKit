//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct SuiObjectResponseQuery: Codable {
    public var filter: SuiObjectDataFilter?
    public var options: SuiObjectDataOptions?
}
