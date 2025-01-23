//
//  ExecutionStatusType.swift
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

/// `ExecutionStatusType` describes the status of a given execution process.
///
/// - `success`: Indicates that the execution process has successfully completed.
/// - `failure`: Indicates that the execution process has failed.
public enum ExecutionStatusType: String, Equatable {
    /// Represents a successful execution.
    case success

    /// Represents a failed execution.
    case failure

    /// Creates an `ExecutionStatusType` from a JSON object.
    ///
    /// - Parameters:
    ///     - input: The JSON object containing the string representation of the execution status.
    /// - Returns: An `ExecutionStatusType` value if the JSON object contains a valid string ("success" or "failure"), or `nil` otherwise.
    public static func fromJSON(_ input: JSON) -> ExecutionStatusType? {
        switch input.stringValue {
        case "success":
            return .success
        case "failure":
            return .failure
        default:
            return nil
        }
    }
}
