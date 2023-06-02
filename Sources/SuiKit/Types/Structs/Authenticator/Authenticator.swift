//
//  Authenticator.swift
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

/// sui Blockchain Authenticator
public struct Authenticator: Equatable, KeyProtocol {
    public static let ed25519: Int = 0
    public static let multiEd25519: Int = 1
    public static let multiAgent: Int = 2

    let variant: Int
    let authenticator: any AuthenticatorProtocol

    init(authenticator: any AuthenticatorProtocol) throws {
        if authenticator is Ed25519Authenticator {
            variant = Authenticator.ed25519
        } else if authenticator is MultiEd25519Authenticator {
            variant = Authenticator.multiEd25519
        } else if authenticator is MultiAgentAuthenticator {
            variant = Authenticator.multiAgent
        } else {
            throw SuiError.invalidAuthenticatorType
        }
        self.authenticator = authenticator
    }

    public static func == (lhs: Authenticator, rhs: Authenticator) -> Bool {
        return lhs.variant == rhs.variant && lhs.authenticator.isEqualTo(rhs.authenticator)
    }

    /// Verifies the authenticity of a given data.
    ///
    /// This function attempts to verify the authenticity of the given data using the authenticator's verify method.
    ///
    /// - Parameter data: The data to verify.
    ///
    /// - Throws: An error of type AuthenticatorError if there was an error during the verification process.
    ///
    /// - Returns: A boolean value indicating whether the given data is authentic or not.
    public func verify(_ data: Data) throws -> Bool {
        return try self.authenticator.verify(data)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Authenticator {
        let variant = try deserializer.uleb128()

        var authenticator: any AuthenticatorProtocol

        if variant == Authenticator.ed25519 {
            authenticator = try Ed25519Authenticator.deserialize(from: deserializer)
        } else if variant == Authenticator.multiEd25519 {
            authenticator = try MultiEd25519Authenticator.deserialize(from: deserializer)
        } else if variant == Authenticator.multiAgent {
            authenticator = try MultiAgentAuthenticator.deserialize(from: deserializer)
        } else {
            throw SuiError.invalidType(type: String(variant))
        }

        return try Authenticator(authenticator: authenticator)
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(variant))
        try Serializer._struct(serializer, value: self.authenticator)
    }
}
