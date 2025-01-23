//
//  RPCErrorValue.swift
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

/// Represents a structured error value for Remote Procedure Call (RPC).
public struct RPCErrorValue: Error, Equatable {
    /// A unique identifier for the RPC call. It can be `nil` if the error is in response to a
    /// notification (i.e., a request where a response is not expected).
    public let id: Int?

    /// A structured object describing the error, providing more details about what went wrong.
    /// This could be `nil` if there is no detailed error message available.
    public let error: ErrorMessage?

    /// A string specifying the version of the JSON-RPC protocol.
    /// This can be `nil` if the protocol version is not specified.
    public let jsonrpc: String?

    /// A boolean indicating whether an error has occurred. It will be `true` if an error
    /// is present, otherwise `false`.
    public let hasError: Bool
}
