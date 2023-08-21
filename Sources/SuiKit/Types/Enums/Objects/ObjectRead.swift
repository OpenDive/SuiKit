//
//  ObjectRead.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

public enum ObjectRead {
    case versionFound(SuiObjectData)
    case objectNotExists(String)
    case objectDeleted(SuiObjectRef)
    case versionNotFound(String, String)
    case versionTooHigh(askedVersion: String, latestVersion: String, objectId: String)

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
