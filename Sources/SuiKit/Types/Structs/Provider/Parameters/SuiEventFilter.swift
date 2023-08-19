//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum SuiEventFilter: Codable {
    private enum CodingKeys: String, CodingKey {
        case sender = "Sender"
        case transaction = "Transaction"
        case package = "Package"
        case moveModule = "MoveModule"
        case moveEventType = "MoveEventType"
        case moveEventModule = "MoveEventModule"
        case moveEventField = "MoveEventField"
        case timeRange = "TimeRange"
        case any = "Any"
        case all = "All"
        case and = "And"
        case or = "Or"
    }

    case sender(String)
    case transaction(String)
    case package(String)
    case moveModule(MoveModuleFilter)
    case moveEventType(String)
    case moveEventModule(MoveModuleFilter)
    case moveEventField(MoveEventField)
    case timeRange(TimeRange)
    case any([SuiEventFilter])
    case all([SuiEventFilter])
    case and([SuiEventFilter])
    case or([SuiEventFilter])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sender(let string):
            try container.encode(string, forKey: .sender)
        case .transaction(let string):
            try container.encode(string, forKey: .transaction)
        case .package(let string):
            try container.encode(string, forKey: .package)
        case .moveModule(let moveModuleFilter):
            try container.encode(moveModuleFilter, forKey: .moveModule)
        case .moveEventType(let string):
            try container.encode(string, forKey: .moveEventType)
        case .moveEventModule(let moveModuleFilter):
            try container.encode(moveModuleFilter, forKey: .moveEventModule)
        case .moveEventField(let moveEventField):
            try container.encode(moveEventField, forKey: .moveEventField)
        case .timeRange(let timeRange):
            try container.encode(timeRange, forKey: .timeRange)
        case .any(let array):
            try container.encode(array, forKey: .any)
        case .all(let array):
            try container.encode(array, forKey: .all)
        case .and(let array):
            try container.encode(array, forKey: .and)
        case .or(let array):
            try container.encode(array, forKey: .or)
        }
    }
}
