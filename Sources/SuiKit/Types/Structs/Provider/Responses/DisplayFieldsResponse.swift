//
//  DisplayFieldsResponse.swift
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

/// A structure representing the response containing display fields.
public struct DisplayFieldsResponse: Equatable {
    /// An optional dictionary containing the display data.
    /// The keys are `String` representing the field names and the values are `String` representing the field values.
    /// This will be `nil` if there is no display data to represent.
    public var data: [String: String]?

    /// An optional instance of `ObjectResponseError` representing any error that occurred while generating the response.
    /// This will be `nil` if there is no error to report.
    public var error: ObjectResponseError?

    public init(graphql: [RPC_OBJECT_FIELDS.Display]) {
        var data: [String: String] = [:]
        var error: ObjectResponseError?
        for displayItem in graphql {
            if displayItem.error != nil {
                error = ObjectResponseError.parseJSON(JSON(displayItem.error!))
            } else if displayItem.value != nil {
                data[displayItem.key] = displayItem.value!
            }
        }
        self.data = data.isEmpty ? nil : data
        self.error = error
    }

    public init(graphql: [RPC_MOVE_OBJECT_FIELDS.Display]) {
        var data: [String: String] = [:]
        var error: ObjectResponseError?
        for displayItem in graphql {
            if displayItem.error != nil {
                error = ObjectResponseError.parseJSON(JSON(displayItem.error!))
            } else if displayItem.value != nil {
                data[displayItem.key] = displayItem.value!
            }
        }
        self.data = data.isEmpty ? nil : data
        self.error = error
    }

    public init(data: [String: String]? = nil, error: ObjectResponseError? = nil) {
        self.data = data
        self.error = error
    }

    public static func parseJSON(_ input: JSON) -> DisplayFieldsResponse? {
        var error: ObjectResponseError?
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
