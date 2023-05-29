//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public enum TransactionArgumentKind: Codable {
    case object
    case pure(type: String)
    
    public func asString() -> String {
        switch self {
        case .object: return "object"
        case .pure: return "pure"
        }
    }
}
