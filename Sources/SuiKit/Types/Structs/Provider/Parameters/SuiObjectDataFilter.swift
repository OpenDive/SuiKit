//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public enum SuiObjectDataFilter: Codable {
    case MatchAll([SuiObjectDataFilter])
    case MatchAny([SuiObjectDataFilter])
    case MatchNone([SuiObjectDataFilter])
    case Package(String)
    case MoveModule(MoveModuleFilter)
    case StructType(String)
    case AddressOwner(String)
    case ObjectOwner(String)
    case ObjectId(String)
    case ObjectIds([String])
    case Version(String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .MatchAll(let array):
            try container.encode(array, forKey: .MatchAll)
        case .MatchAny(let array):
            try container.encode(array, forKey: .MatchAny)
        case .MatchNone(let array):
            try container.encode(array, forKey: .MatchNone)
        case .Package(let string):
            try container.encode(string, forKey: .Package)
        case .MoveModule(let moveModuleFilter):
            try container.encode(moveModuleFilter, forKey: .MoveModule)
        case .StructType(let string):
            try container.encode(string, forKey: .StructType)
        case .AddressOwner(let string):
            try container.encode(string, forKey: .AddressOwner)
        case .ObjectOwner(let string):
            try container.encode(string, forKey: .ObjectOwner)
        case .ObjectId(let string):
            try container.encode(string, forKey: .ObjectId)
        case .ObjectIds(let array):
            try container.encode(array, forKey: .ObjectId)
        case .Version(let string):
            try container.encode(string, forKey: .Version)
        }
    }
}
