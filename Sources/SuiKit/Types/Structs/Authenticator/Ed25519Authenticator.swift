//
//  Ed25519Authenticator.swift
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

public struct Ed25519Authenticator: AuthenticatorProtocol {
    public let publicKey: PublicKey
    public let signature: Signature

    public func verify(_ data: Data) throws -> Bool {
        return try self.publicKey.verify(data: data, signature: self.signature)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Ed25519Authenticator {
        let key = try deserializer._struct(type: PublicKey.self)
        let signature = try deserializer._struct(type: Signature.self)
        return Ed25519Authenticator(publicKey: key, signature: signature)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.publicKey)
        try Serializer._struct(serializer, value: self.signature)
    }

    public func isEqualTo(_ rhs: any AuthenticatorProtocol) -> Bool {
        guard let APrhs = rhs as? Ed25519Authenticator else { return false }
        return self.publicKey == APrhs.publicKey && self.signature == APrhs.signature
    }
}
