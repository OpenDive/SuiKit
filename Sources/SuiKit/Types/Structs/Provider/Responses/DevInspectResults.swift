//
//  DevInspectResults.swift
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

/// A structure representing the results of DevInspect call.
public struct DevInspectResults {
    /// An instance of `TransactionEffects` representing the effects of the transaction.
    public var effects: TransactionEffects

    /// An optional array of `ExecutionResultType` representing the results of the execution.
    /// This will be `nil` if there are no execution results to represent.
    public var results: [ExecutionResultType]?

    /// An optional `String` representing any error that occurred during the inspection.
    /// This will be `nil` if there is no error to report.
    public var error: String?

    /// An array of `SuiEvent` representing the events that occurred during the inspection.
    public var events: [SuiEvent]

    public init?(input: JSON) {
        guard let effects = TransactionEffects(input: input["effects"]) else { return nil }
        self.effects = effects
        self.error = input["error"].string
        self.events = input["events"].arrayValue.compactMap { SuiEvent(input: $0) }
        self.results = input["results"].arrayValue.compactMap { ExecutionResultType(input: $0) }
    }
}
