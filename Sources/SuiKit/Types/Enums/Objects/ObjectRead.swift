//
//  ObjectRead.swift
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

/// `ObjectRead` describes the result of attempting to read an object in the Sui blockchain ecosystem.
public enum ObjectRead {
    /// Indicates that the object's version was successfully found. The associated value is the found `SuiObjectData`.
    case versionFound(SuiObjectData)

    /// Indicates that the object does not exist. The associated value is a `String` containing the object's identifier.
    case objectNotExists(String)

    /// Indicates that the object has been deleted. The associated value is a `SuiObjectRef` reference to the deleted object.
    case objectDeleted(SuiObjectRef)

    /// Indicates that the requested version of the object was not found. The associated values are `String`s containing the object ID and the requested version.
    case versionNotFound(String, String)

    /// Indicates that the requested version is higher than the latest version. The associated values are `String`s containing the asked version, the latest version, and the object ID.
    case versionTooHigh(askedVersion: String, latestVersion: String, objectId: String)

    /// Parses a `JSON` object to produce an `ObjectRead` object.
    ///
    /// - Parameters:
    ///   - data: The JSON object representing the read object's status.
    /// - Returns: An `ObjectRead` object based on the parsed JSON, or `nil` if parsing fails.
    ///
    /// The function attempts to parse the JSON object to determine the result of an object read operation.
    public static func parseJSON(_ data: JSON) -> ObjectRead? {
        switch data["status"].stringValue {
        case "VersionFound":
            guard let versionFound = SuiObjectData(data: data["details"]) else { return nil }
            return .versionFound(versionFound)
        case "ObjectNotExists":
            return .objectNotExists(data["details"].stringValue)
        case "ObjectDeleted":
            return .objectDeleted(SuiObjectRef(input: data["details"]))
        case "VersionNotFound":
            return .versionNotFound(
                data["details"].arrayValue[0].stringValue,
                data["details"].arrayValue[1].stringValue
            )
        case "VersionTooHigh":
            return .versionTooHigh(
                askedVersion: data["details"]["askedVersion"].stringValue,
                latestVersion: data["details"]["latestVersion"].stringValue,
                objectId: data["details"]["objectId"].stringValue
            )
        default:
            return nil
        }
    }

    /// Retrieves the status as a `String`.
    ///
    /// - Returns: A `String` representing the status of the `ObjectRead`.
    ///
    /// This function converts the `ObjectRead` case into a `String` that can be easily read or transmitted.
    public func status() -> String {
        switch self {
        case .versionFound:
            return "VersionFound"
        case .objectNotExists:
            return "ObjectNotExists"
        case .objectDeleted:
            return "ObjectDeleted"
        case .versionNotFound:
            return "VersionNotFound"
        case .versionTooHigh:
            return "VersionTooHigh"
        }
    }
}
