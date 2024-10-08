//
//  ProtocolConfig.swift
//  SuiKit
//
//  Copyright (c) 2024 OpenDive
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

public struct ProtocolConfig: Equatable {
    /// A dictionary containing attributes related to the protocol configuration.
    /// The keys are strings representing the name of the attribute,
    /// and the values are optional `ProtocolConfigValue` instances representing the value of the attribute.
    public let attributes: [String: ProtocolConfigValue?]

    /// A dictionary containing feature flags related to the protocol configuration.
    /// The keys are strings representing the name of the feature flag,
    /// and the values are Booleans representing whether the feature is enabled (`true`) or disabled (`false`).
    public let featureFlags: [String: Bool]

    /// A string representing the maximum supported protocol version.
    public let maxSupportedProtocolVersion: String

    /// A string representing the minimum supported protocol version.
    public let minSupportedProtocolVersion: String

    /// A string representing the current protocol version.
    public let protocolVersion: String

    /// Initializes a new instance of `ProtocolConfig`.
    ///
    /// - Parameters:
    ///   - attributes: A dictionary representing the attributes of the protocol configuration.
    ///   - featureFlags: A dictionary representing the feature flags of the protocol configuration.
    ///   - maxSupportedProtocolVersion: A string representing the maximum supported protocol version.
    ///   - minSupportedProtocolVersion: A string representing the minimum supported protocol version.
    ///   - protocolVersion: A string representing the current protocol version.
    public init(
        attributes: [String: ProtocolConfigValue?],
        featureFlags: [String: Bool],
        maxSupportedProtocolVersion: String,
        minSupportedProtocolVersion: String,
        protocolVersion: String
    ) {
        self.attributes = attributes
        self.featureFlags = featureFlags
        self.maxSupportedProtocolVersion = maxSupportedProtocolVersion
        self.minSupportedProtocolVersion = minSupportedProtocolVersion
        self.protocolVersion = protocolVersion
    }
}

