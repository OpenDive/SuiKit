//
//  SuiObjectChange.swift
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

/// `SuiObjectChange` represents the type of change that occurred on a SuiObject.
///
/// - `published`: The object has been published.
/// - `transferred`: The object has been transferred.
/// - `mutated`: The object has been mutated.
/// - `deleted`: The object has been deleted.
/// - `wrapped`: The object has been wrapped.
/// - `created`: The object has been created.
public enum SuiObjectChange {
    /// Represents a published object change.
    case published(SuiObjectChangePublished)

    /// Represents a transferred object change.
    case transferred(SuiObjectChangeTransferred)

    /// Represents a mutated object change.
    case mutated(SuiObjectChangeMutated)

    /// Represents a deleted object change.
    case deleted(SuiObjectChangeDeleted)

    /// Represents a wrapped object change.
    case wrapped(SuiObjectChangeWrapped)

    /// Represents a created object change.
    case created(SuiObjectChangeCreated)

    /// Creates a `SuiObjectChange` instance from a JSON object.
    public static func fromJSON(_ input: JSON) -> SuiObjectChange? {
        switch input["type"].stringValue {
        case "published":
            return .published(SuiObjectChangePublished(input: input))
        case "transferred":
            guard let transferred = SuiObjectChangeTransferred(input: input) else { return nil }
            return .transferred(transferred)
        case "mutated":
            guard let mutated = SuiObjectChangeMutated(input: input) else { return nil }
            return .mutated(mutated)
        case "deleted":
            guard let deleted = SuiObjectChangeDeleted(input: input) else { return nil }
            return .deleted(deleted)
        case "wrapped":
            guard let wrapped = SuiObjectChangeWrapped(input: input) else { return nil }
            return .wrapped(wrapped)
        case "created":
            guard let created = SuiObjectChangeCreated(input: input) else { return nil }
            return .created(created)
        default:
            return nil
        }
    }

    /// Returns the kind of object change as a string.
    var kind: String {
        switch self {
        case .published:
            return "published"
        case .transferred:
            return "transferred"
        case .mutated:
            return "mutated"
        case .deleted:
            return "deleted"
        case .wrapped:
            return "wrapped"
        case .created:
            return "created"
        }
    }
}
