//
//  SuiTransactionKind.swift
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

/// Represents the names of the different kinds of Sui framework transactions
public enum SuiTransactionKind: String {
    /// Transaction type for moving calls.
    case moveCall = "MoveCall"

    /// Transaction type for transferring objects.
    case transferObjects = "TransferObjects"

    /// Transaction type for splitting coins.
    case splitCoins = "SplitCoins"

    /// Transaction type for merging coins.
    case mergeCoins = "MergeCoins"

    /// Transaction type for publishing.
    case publish = "Publish"

    /// Transaction type for creating a vector in the Move language.
    case makeMoveVec = "MakeMoveVec"

    /// Transaction type for upgrades.
    case upgrade = "Upgrade"
}
