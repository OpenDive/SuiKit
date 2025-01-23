//
//  TransferPolicyConstants.swift
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

public struct TransferPolicyConstants {
    /// The Transfer Policy module.
    public static let transferPolicyModule = "0x2::transfer_policy"

    /// Name of the event emitted when a TransferPolicy for T is created.
    public static let transferPolicyCreatedEvent = "\(transferPolicyModule)::TransferPolicyCreated"

    /// The Transfer Policy Type
    public static let transferPolicyType = "\(transferPolicyModule)::TransferPolicy"

    /// The Transfer Policy Cap Type
    public static let transferPolicyCapType = "\(transferPolicyModule)::TransferPolicyCap"

    /// The Kiosk Lock Rule
    public static let kioskLockRule = "kiosk_lock_rule::Rule"

    /// The Royalty rule
    public static let royaltyRule = "royalty_rule::Rule"
}
