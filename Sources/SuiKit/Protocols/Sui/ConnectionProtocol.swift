//
//  ConnectionProtocol.swift
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
/// Protocol defining the requirements for a connection configuration.
public protocol ConnectionProtocol: Sendable {
    /// The URL or IP address of the full node to connect to.
    var fullNode: String { get }

    /// Optional URL for a faucet service to obtain tokens.
    /// Default is nil, meaning no faucet is configured.
    var faucet: String? { get }

    var graphql: String? { get }

    /// Optional URL for a WebSocket connection.
    /// Default is nil, meaning no WebSocket is configured.
    var websocket: String? { get }
}
#elseif swift(<6.0)
/// Protocol defining the requirements for a connection configuration.
public protocol ConnectionProtocol {
    /// The URL or IP address of the full node to connect to.
    var fullNode: String { get }

    /// Optional URL for a faucet service to obtain tokens.
    /// Default is nil, meaning no faucet is configured.
    var faucet: String? { get }

    var graphql: String? { get }

    /// Optional URL for a WebSocket connection.
    /// Default is nil, meaning no WebSocket is configured.
    var websocket: String? { get }
}
#endif

// MARK: - Default Implementations
public extension ConnectionProtocol {
    /// Default implementation returns nil, indicating that a faucet is not configured.
    var faucet: String? {
        get { return nil }
    }

    /// Default implementation returns nil, indicating that a WebSocket is not configured.
    var websocket: String? {
        get { return nil }
    }
}
