//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation

public enum SuiRequestType: String, Codable {
    case waitforEffectsCert = "WaitForEffectsCert"
    case waitForLocalExecution = "WaitForLocalExecution"
}
