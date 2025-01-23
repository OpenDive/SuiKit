//
//  BuildOptions.swift
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

public struct BuildOptions {
    /// A `SuiProvider` object that provides network connectivity.
    /// It is optional and can be `nil`.
    public var provider: SuiProvider?

    /// A Boolean that specifies whether only a transaction kind is allowed.
    /// It is optional and can be `nil`.
    public var onlyTransactionKind: Bool?

    /// Represents the limits like maximum gas, transaction size etc.
    /// It is optional and can be `nil`.
    public var limits: Limits?

    /// Represents the protocol configurations including attributes, feature flags and version details.
    /// It is optional and can be `nil`.
    public var protocolConfig: ProtocolConfig?

    /// A dictionary containing string keys and values representing various limits.
    /// For example, it can include the maximum gas allowed, maximum transaction size etc.
    public static let limits: [String: String] = [
        "maxTxGas": "max_tx_gas",
        "maxGasObjects": "max_gas_payment_objects",
        "maxTxSizeBytes": "max_tx_size_bytes",
        "maxPureArgumentSize": "max_pure_argument_size"
    ]

    /// Initializes a new instance of `BuildOptions` with optional parameters.
    /// - Parameters:
    ///   - provider: A `SuiProvider` object, default is `nil`.
    ///   - onlyTransactionKind: A Boolean value, default is `nil`.
    ///   - limits: A `Limits` object, default is `nil`.
    ///   - protocolConfig: A `ProtocolConfig` object, default is `nil`.
    public init(
        provider: SuiProvider? = nil,
        onlyTransactionKind: Bool? = nil,
        limits: Limits? = nil,
        protocolConfig: ProtocolConfig? = nil
    ) {
        self.provider = provider
        self.onlyTransactionKind = onlyTransactionKind
        self.limits = limits
        self.protocolConfig = protocolConfig
    }
}
