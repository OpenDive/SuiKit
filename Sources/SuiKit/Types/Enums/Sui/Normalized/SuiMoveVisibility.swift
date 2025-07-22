//
//  SuiMoveVisibility.swift
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

/// Enumeration representing visibility levels in the SuiMove environment.
public enum SuiMoveVisibility: String, Equatable {
    /// Represents a private visibility level, accessible only within the same module.
    case Private

    /// Represents a public visibility level, accessible from any module.
    case Public

    /// Represents a friend visibility level, accessible only by designated friend modules.
    case Friend

    public static func parseGraphQL(_ data: GraphQLEnum<MoveVisibility>?) -> SuiMoveVisibility? {
        guard data != nil else { return nil }
        switch data! {
        case .friend: return .Friend
        case .public: return .Public
        case .private: return .Private
        default: return nil
        }
    }

    /// Function to parse a JSON object into a `SuiMoveVisibility` enum.
    /// - Parameter data: The JSON data to parse.
    /// - Returns: Returns a `SuiMoveVisibility` if it could be parsed, otherwise returns `nil`.
    public static func parseJSON(_ data: JSON) -> SuiMoveVisibility? {
        switch data.stringValue {
        case "Private": return .Private
        case "Public": return .Public
        case "Friend": return .Friend
        default: return nil
        }
    }
}
