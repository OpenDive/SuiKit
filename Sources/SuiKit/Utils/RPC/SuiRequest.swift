//
//  SuiRequest.swift
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
@preconcurrency import AnyCodable

/// `SuiRequest` represents a request structure conforming to JSON-RPC 2.0 specifications.
/// JSON-RPC is a remote procedure call (RPC) protocol encoded in JSON.
public struct SuiRequest: Codable {
    /// Represents a unique identifier for the request. By default, it's assigned a random integer value.
    var id: Int = Int(arc4random())

    /// Represents the name of the method to be invoked.
    var method: String = ""

    /// Represents the version of the JSON-RPC protocol, which is "2.0" in this case.
    var jsonrpc: String = "2.0"

    /// Represents the parameters of the method to be invoked. The parameters are encapsulated in an `AnyCodable` array to support any type that conforms to the `Codable` protocol.
    var params: [AnyCodable]

    public init(_ method: String, _ params: [AnyCodable]) {
        self.method = method
        self.params = params
    }
}
