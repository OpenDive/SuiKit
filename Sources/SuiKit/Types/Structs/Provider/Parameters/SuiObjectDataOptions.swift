//
//  SuiObjectDataOptions.swift
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

/// A structure representing the various display options for SuiObjectData, conforming to `Codable`.
public struct SuiObjectDataOptions: Codable {
    /// An optional `Bool` indicating whether to show BCS representation.
    public var showBcs: Bool?

    /// An optional `Bool` indicating whether to display the content of the object.
    public var showContent: Bool?

    /// An optional `Bool` indicating whether to show the display representation of the object.
    public var showDisplay: Bool?

    /// An optional `Bool` indicating whether to show the owner of the object.
    public var showOwner: Bool?

    /// An optional `Bool` indicating whether to show the previous transaction of the object.
    public var showPreviousTransaction: Bool?

    /// An optional `Bool` indicating whether to show the storage rebate of the object.
    public var showStorageRebate: Bool?

    /// An optional `Bool` indicating whether to show the type of the object.
    public var showType: Bool?

    /// Initializes a new instance of `SuiObjectDataOptions` with the given parameters.
    /// - Parameters:
    ///   - showBcs: A flag indicating whether to show BCS representation.
    ///   - showContent: A flag indicating whether to display the content of the object.
    ///   - showDisplay: A flag indicating whether to show the display representation of the object.
    ///   - showOwner: A flag indicating whether to show the owner of the object.
    ///   - showPreviousTransaction: A flag indicating whether to show the previous transaction of the object.
    ///   - showStorageRebate: A flag indicating whether to show the storage rebate of the object.
    ///   - showType: A flag indicating whether to show the type of the object.
    public init(
        showBcs: Bool? = nil,
        showContent: Bool? = nil,
        showDisplay: Bool? = nil,
        showOwner: Bool? = nil,
        showPreviousTransaction: Bool? = nil,
        showStorageRebate: Bool? = nil,
        showType: Bool? = nil
    ) {
        self.showBcs = showBcs
        self.showContent = showContent
        self.showDisplay = showDisplay
        self.showOwner = showOwner
        self.showPreviousTransaction = showPreviousTransaction
        self.showStorageRebate = showStorageRebate
        self.showType = showType
    }
}
