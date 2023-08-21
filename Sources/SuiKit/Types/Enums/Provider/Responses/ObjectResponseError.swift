//
//  ObjectResponseError.swift
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
