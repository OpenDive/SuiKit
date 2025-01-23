//
//  StakeObject.swift
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

/// Represents a stake object, detailing information regarding a staking process or state,
/// and conforming to the `Equatable` protocol to allow comparisons between instances.
public struct StakeObject: Equatable {
    /// A string representing the principal involved in the stake, usually identifying the
    /// individual, account, or entity that initiated or holds the stake.
    public var principal: String

    /// A string representing the epoch in which the stake became active. Epochs are chronological
    /// units or timeframes used to divide the lifetime of the staking process, and this property
    /// signifies when the stake starts to be in effect.
    public var stakeActiveEpoch: String

    /// A string representing the epoch in which the stake request was made. This property helps
    /// in identifying when the initial request to stake was placed within the chronological
    /// sequence of epochs.
    public var stakeRequestEpoch: String

    /// A string representing the unique identifier associated with this stake in the Sui
    /// Blockchain, enabling reference and lookup of this specific stake instance.
    public var stakeSuiId: String
}
