//
//  BuildOptions.swift
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

public struct BuildOptions {
    public var provider: SuiProvider?
    public var onlyTransactionKind: Bool?
    public var limits: Limits?
    public var protocolConfig: ProtocolConfig?

    public static let limits: [String: String] = [
        // The maximum gas that is allowed.
        "maxTxGas": "max_tx_gas",
        // The maximum number of gas objects that can be selected for one transaction.
        "maxGasObjects": "max_gas_payment_objects",
        // The maximum size (in bytes) that the transaction can be.
        "maxTxSizeBytes": "max_tx_size_bytes",
        // The maximum size (in bytes) that pure arguments can be.
        "maxPureArgumentSize": "max_pure_argument_size"
    ]

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
