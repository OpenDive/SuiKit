//
//  TransactionBlockResponseOptions.swift
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

public struct TransactionBlockResponseOptions: Codable {
    public var showInput: Bool
    public var showRawInput: Bool
    public var showEffects: Bool
    public var showEvents: Bool
    public var showObjectChanges: Bool
    public var showBalanceChanges: Bool

    public init(
        showInput: Bool = true,
        showRawInput: Bool = true,
        showEffects: Bool = true,
        showEvents: Bool = true,
        showObjectChanges: Bool = true,
        showBalanceChanges: Bool = true
    ) {
        self.showInput = showInput
        self.showRawInput = showRawInput
        self.showEffects = showEffects
        self.showEvents = showEvents
        self.showObjectChanges = showObjectChanges
        self.showBalanceChanges = showBalanceChanges
    }
}
