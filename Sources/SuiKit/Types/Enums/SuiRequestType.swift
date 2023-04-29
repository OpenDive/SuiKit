//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation

public enum SuiRequestType: Int {
    case waitforEffectsCert = 0
    case waitForLocalExecution = 1
    
    public func asString() -> String {
        switch self {
        case .waitforEffectsCert:
            return "WaitForEffectsCert"
        case .waitForLocalExecution:
            return "WaitForLocalExecution"
        }
    }
}
