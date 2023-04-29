//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation

public enum SuiTransactionBuilderMode: Int {
    case commit = 0
    case devInspect = 1
    
    public func asString() -> String {
        switch self {
        case .commit:
            return "Commit"
        case .devInspect:
            return "DevInspect"
        }
    }
}
