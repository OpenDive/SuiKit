//
//  RPCErrorRequest.swift
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
@preconcurrency import AnyCodable

/// Protocol defining the requirements for an RPC (Remote Procedure Call) error request.
/// Conforming types are expected to provide a method name and arguments for the RPC call
/// that resulted in an error. This helps in logging, debugging, or handling the error appropriately.
public protocol RPCErrorRequest: Sendable {
    /// The name of the method that was called when the error occurred.
    /// This is generally expected to be the function or API endpoint name.
    var method: String { get set }

    /// The list of arguments that were passed to the method during the call that resulted in an error.
    /// Using `AnyCodable` allows for a flexible array that can contain multiple types, as long as they conform to `Codable`.
    var args: [AnyCodable] { get set }
}
