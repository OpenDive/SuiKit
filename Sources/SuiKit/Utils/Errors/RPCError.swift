//
//  RPCError.swift
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

#if swift(>=6.0)
/// `RPCError` is a class representing an error encountered while performing a Remote Procedure Call (RPC).
final class RPCError: Sendable, Error {
    /// Represents the request associated with the RPC error.
    let req: RPCErrorRequest

    /// Represents the error code, if any, associated with the RPC error. The type of this property is `Any?` as the error code can be of any type.
    let code: String?

    /// Represents additional error data, if any, associated with the RPC error. The type of this property is `Any?` as the error data can be of any type.
    let data: Data?

    /// Represents the underlying cause of the RPC error, if any.
    let cause: Error?

    init(options: (req: RPCErrorRequest, code: String?, data: Data?, cause: Error?)) {
        self.req = options.req
        self.code = options.code
        self.data = options.data
        self.cause = options.cause
    }
}
#elseif swift(<6.0)
/// `RPCError` is a class representing an error encountered while performing a Remote Procedure Call (RPC).
final class RPCError: Error {
    /// Represents the request associated with the RPC error.
    let req: RPCErrorRequest

    /// Represents the error code, if any, associated with the RPC error. The type of this property is `Any?` as the error code can be of any type.
    let code: String?

    /// Represents additional error data, if any, associated with the RPC error. The type of this property is `Any?` as the error data can be of any type.
    let data: Data?

    /// Represents the underlying cause of the RPC error, if any.
    let cause: Error?

    init(options: (req: RPCErrorRequest, code: String?, data: Data?, cause: Error?)) {
        self.req = options.req
        self.code = options.code
        self.data = options.data
        self.cause = options.cause
    }
}
#endif
