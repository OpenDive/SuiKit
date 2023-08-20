//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public enum ObjectValueKind: String, Equatable {
    case byImmutableReference = "ByImmutableReference"
    case byMutableReference = "ByMutableReference"
    case byValue = "ByValue"
}
