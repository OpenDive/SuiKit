//
//  SuiEventFilter.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
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

/// `SuiEventFilter` defines various filters that can be applied to events in the Sui blockchain ecosystem.
///
/// The enum supports different types of event filters such as sender, transaction, package, etc.
/// It also provides compound filtering capabilities like `any`, `all`, `and`, and `or`.
public enum SuiEventFilter: Codable {
    /// Keys used for encoding and decoding the enum cases.
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

    /// Filter events by sender's address.
    case sender(String)

    /// Filter events by transaction ID.
    case transaction(String)

    /// Filter events by package ID.
    case package(String)

    /// Filter events by Move module characteristics.
    case moveModule(MoveModuleFilter)

    /// Filter events by Move event type.
    case moveEventType(String)

    /// Filter events by Move module attributes related to the event.
    case moveEventModule(MoveModuleFilter)

    /// Filter events by Move event fields.
    case moveEventField(MoveEventField)

    /// Filter events occurring within a specified time range.
    case timeRange(TimeRange)

    /// Match any of the provided filters.
    case any([SuiEventFilter])

    /// Match all of the provided filters.
    case all([SuiEventFilter])

    /// Logical AND between the provided filters.
    case and([SuiEventFilter])

    /// Logical OR between the provided filters.
    case or([SuiEventFilter])

    /// Encode the enum into a container.
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
