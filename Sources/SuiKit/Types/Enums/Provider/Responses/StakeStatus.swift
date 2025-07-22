//
//  StakeStatus.swift
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

/// `StakeStatus` represents the status of a stake in a staking system.
///
/// - `pending`: The stake is in a pending state and is not yet active.
/// - `active`: The stake is active and participating in the staking system.
/// - `unstaked`: The stake has been unstaked and is no longer participating.
public enum StakeStatus: Equatable {
    /// The stake is in a pending state and is not yet active.
    case pending(StakeObject)

    /// The stake is active and participating.
    case active(StakeObject)

    /// The stake has been unstaked and is no longer participating.
    case unstaked(StakeObject)

    /// Retrieve the `StakeObject` associated with the current status.
    ///
    /// - Returns: The associated `StakeObject`.
    public func getStakeObject() -> StakeObject {
        switch self {
        case .pending(let stakeObject):
            return stakeObject
        case .active(let stakeObject):
            return stakeObject
        case .unstaked(let stakeObject):
            return stakeObject
        }
    }
}
