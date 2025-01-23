//
//  SuiTransactionBlockResponseOptions.swift
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

public struct SuiTransactionBlockResponseOptions: Codable {
    /// An optional `Bool` indicating whether to show the input in the transaction block response.
    public let showInput: Bool?

    /// An optional `Bool` indicating whether to show the effects in the transaction block response.
    public let showEffects: Bool?

    /// An optional `Bool` indicating whether to show the events in the transaction block response.
    public let showEvents: Bool?

    /// An optional `Bool` indicating whether to show the object changes in the transaction block response.
    public let showObjectChanges: Bool?

    /// An optional `Bool` indicating whether to show the balance changes in the transaction block response.
    public let showBalanceChanges: Bool?

    public init(
        showInput: Bool? = nil,
        showEffects: Bool? = nil,
        showEvents: Bool? = nil,
        showObjectChanges: Bool? = nil,
        showBalanceChanges: Bool? = nil
    ) {
        self.showInput = showInput
        self.showEffects = showEffects
        self.showEvents = showEvents
        self.showObjectChanges = showObjectChanges
        self.showBalanceChanges = showBalanceChanges
    }
}
