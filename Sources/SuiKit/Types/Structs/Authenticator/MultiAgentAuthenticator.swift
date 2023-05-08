//
//  MultiAgentAuthenticator.swift
//  AptosKit
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

public struct MultiAgentAuthenticator: AuthenticatorProtocol {
    public var sender: Authenticator
    public var secondarySigner: [(AccountAddress, Authenticator)]

    /// Returns all of the account addresses of the secondary signers.
    /// - Returns: An array of AccountAddress objects
    public func secondaryAddresses() -> [AccountAddress] {
        return secondarySigner.map { $0.0 }
    }

    public func verify(_ data: Data) throws -> Bool {
        if !(try self.sender.verify(data)) {
            return false
        }
        return !(try secondarySigner.map { try $0.1.verify(data) }.contains(false))
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MultiAgentAuthenticator {
        let sender = try deserializer._struct(type: Authenticator.self)
        let secondaryAddresses = try deserializer.sequence(valueDecoder: AccountAddress.deserialize)
        let secondaryAuthenticator = try deserializer.sequence(valueDecoder: Authenticator.deserialize)
        return MultiAgentAuthenticator(sender: sender, secondarySigner: Array(zip(secondaryAddresses, secondaryAuthenticator)))
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.sender)
        try serializer.sequence(self.secondarySigner.map { $0.0 }, Serializer._struct)
        try serializer.sequence(self.secondarySigner.map { $0.1 }, Serializer._struct)
    }

    public func isEqualTo(_ rhs: AuthenticatorProtocol) -> Bool {
        guard let APrhs = rhs as? MultiAgentAuthenticator else { return false }
        for (signer, rhsSigner) in zip(self.secondarySigner, APrhs.secondarySigner) {
            if signer.0 != rhsSigner.0 || signer.1 != rhsSigner.1 {
                return false
            }
        }
        return self.sender == APrhs.sender
    }
}
