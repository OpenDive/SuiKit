//
//  SuiEventFilter.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
