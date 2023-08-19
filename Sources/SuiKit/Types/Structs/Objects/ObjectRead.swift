//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
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
            guard let objectDeleted = SuiObjectRef(input: data["details"]) else { return nil }
            return .objectDeleted(objectDeleted)
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
