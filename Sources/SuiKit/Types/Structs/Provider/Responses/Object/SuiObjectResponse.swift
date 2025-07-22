//
//  SuiObjectResponse.swift
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

/// A structure representing the response from a request for a SuiObject, containing either the object data or an error.
public struct SuiObjectResponse: Equatable {
    /// An optional `ObjectResponseError` representing any error that occurred during the request for the SuiObject.
    public var error: ObjectResponseError?

    /// An optional `SuiObjectData` representing the data of the requested SuiObject, if the request was successful.
    public var data: SuiObjectData?

    /// Retrieves the initial version of the shared object, if applicable.
    ///
    /// This method will return `nil` if the `data` is `nil` or if the owner of the object is not shared.
    /// - Returns: An optional `Int` representing the initial version of the shared object.
    public func getSharedObjectInitialVersion() -> Int? {
        guard let owner = self.data?.owner else { return nil }
        switch owner {
        case .shared(let shared):
            return shared
        default:
            return nil
        }
    }

    /// Constructs and retrieves a `SuiObjectRef` reference from the object data, if available.
    ///
    /// This method will return `nil` if the `data` is `nil`.
    /// - Returns: An optional `SuiObjectRef` representing the object reference constructed from the object data.
    public func getObjectReference() -> SuiObjectRef? {
        guard let data = self.data else { return nil }
        return SuiObjectRef(
            objectId: data.objectId,
            version: data.version,
            digest: data.digest
        )
    }

    public init(error: ObjectResponseError? = nil, data: SuiObjectData? = nil) {
        self.error = error
        self.data = data
    }

    public init?(input: JSON) {
        var error: ObjectResponseError?
        if input["error"].exists() {
            error = ObjectResponseError.parseJSON(input["error"])
        }
        let data = input["data"]
        self.error = error
        self.data = SuiObjectData(data: data)
    }
}
