//
//  zkLoginIntentScope.swift
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

/// Intent scope for zkLogin signature verification, matching the GraphQL schema
public enum ZkLoginIntentScope: String, CaseIterable {
    /// Indicates that the bytes are to be parsed as transaction data bytes
    case transactionData = "TRANSACTION_DATA"
    
    /// Indicates that the bytes are to be parsed as a personal message
    case personalMessage = "PERSONAL_MESSAGE"
}

/// Result of zkLogin signature verification from GraphQL
public struct zkLoginVerifyResult {
    /// The boolean result of the verification. If true, errors should be empty.
    public let success: Bool
    
    /// The errors field captures any verification error
    public let errors: [String]
    
    public init(success: Bool, errors: [String]) {
        self.success = success
        self.errors = errors
    }
} 