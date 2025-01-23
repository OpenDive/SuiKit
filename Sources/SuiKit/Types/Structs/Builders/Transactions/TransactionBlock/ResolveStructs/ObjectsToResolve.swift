//
//  ObjectsToResolve.swift
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

public struct ObjectsToResolve {
    /// A string representing the unique identifier of the `ObjectsToResolve`.
    let id: String

    /// A `TransactionBlockInput` instance representing the input associated with the object.
    var input: TransactionBlockInput

    /// An optional `SuiMoveNormalizedType` representing the normalized type of the object.
    /// It is `nil` if the normalized type is not defined or available.
    let normalizedType: SuiMoveNormalizedType?

    /// Initializes a new instance of `ObjectsToResolve`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the object.
    ///   - input: The `TransactionBlockInput` associated with the object.
    ///   - normalizedType: The normalized type of the object. Defaults to `nil`.
    public init(id: String, input: TransactionBlockInput, normalizedType: SuiMoveNormalizedType? = nil) {
        self.id = id
        self.input = input
        self.normalizedType = normalizedType
    }
}
