//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct DisplayFieldsResponse {
    public var data: [String: String]?
    public var error: ObjectResponseError?

    public static func parseJSON(_ input: JSON) -> DisplayFieldsResponse? {
        var error: ObjectResponseError? = nil
        if input["error"].exists() {
            error = ObjectResponseError.parseJSON(input["error"])
        }
        var data: [String: String] = [:]
        for (key, value) in input["data"].dictionaryValue {
            data[key] = value.stringValue
        }
        return DisplayFieldsResponse(data: data, error: error)
    }
}
