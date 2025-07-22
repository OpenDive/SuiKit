//
//  ObjectResponseError.swift
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

/// `ObjectResponseError` represents different types of errors that can occur when dealing with object responses.
///
/// - `notExist`: Indicates that an object with the given ID does not exist.
/// - `dynamicFieldNotFound`: Indicates that a dynamic field is not found within the parent object.
/// - `deleted`: Indicates that the object has been deleted, and additional details are provided.
/// - `unknown`: Represents an unknown error.
/// - `displayError`: Indicates that there's a display error, and the details are given as a string.
public enum ObjectResponseError: Error, Equatable {
    /// Indicates that an object with the given ID does not exist.
    case notExist(objectId: String)

    /// Indicates that a dynamic field is not found within the parent object.
    case dynamicFieldNotFound(parentObjectId: String)

    /// Indicates that the object has been deleted. The digest, object ID, and version are provided for context.
    case deleted(digest: String, objectId: String, version: String)

    /// Represents an unknown error.
    case unknown

    /// Indicates that there's a display error. The details are provided as a string.
    case displayError(error: String)

    /// Parses an `ObjectResponseError` from a JSON object.
    ///
    /// - Parameter input: The JSON object containing the error information.
    /// - Returns: An `ObjectResponseError` value if the JSON object contains valid information, or `nil` otherwise.
    public static func parseJSON(_ input: JSON) -> ObjectResponseError? {
        switch input["code"].stringValue {
        case "notExist":
            return .notExist(objectId: input["objectId"].stringValue)
        case "dynamicFieldNotFound":
            return .dynamicFieldNotFound(parentObjectId: input["parentObjectId"].stringValue)
        case "deleted":
            return .deleted(
                digest: input["digest"].stringValue,
                objectId: input["objectId"].stringValue,
                version: input["version"].stringValue
            )
        case "unknown":
            return .unknown
        case "displayError":
            return .displayError(error: input["error"].stringValue)
        default:
            return nil
        }
    }
}
