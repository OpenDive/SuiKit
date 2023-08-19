//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum ObjectResponseError: Error, Equatable {
    case notExist(objectId: String)
    case dynamicFieldNotFound(parentObjectId: String)
    case deleted(digest: String, objectId: String, version: String)
    case unknown
    case displayError(error: String)

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
