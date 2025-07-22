//
//  MessageVersion.swift
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

/// `MessageVersion` represents different versions of messages.
///
/// - `v1`: Represents version 1 of the message.
public enum MessageVersion: String {
    /// Represents version 1 of the message.
    case v1

    /// Creates a `MessageVersion` from a JSON object.
    ///
    /// - Parameters:
    ///     - input: The JSON object containing the string representation of the message version.
    /// - Returns: A `MessageVersion` value if the JSON object contains a valid string ("v1"), or `nil` otherwise.
    public static func fromJSON(_ input: JSON) -> MessageVersion? {
        switch input.stringValue {
        case "v1":
            return .v1
        default:
            return nil
        }
    }
}
