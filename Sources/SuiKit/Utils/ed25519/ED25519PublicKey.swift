//
//  PublicKey.swift
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
import ed25519swift

/// The ED25519 Public Key
public struct ED25519PublicKey: Equatable, PublicKeyProtocol {
    public var type: KeyType = .ed25519
    
    /// The length of the key in bytes
    public static let LENGTH: Int = 32

    /// The key itself
    public var key: Data

    public init(data: Data) throws {
        guard data.count <= ED25519PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = data
    }

    public static func == (lhs: ED25519PublicKey, rhs: ED25519PublicKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return "0x\(key.hexEncodedString())"
    }

    /// Verify a digital signature for a given data using Ed25519 algorithm.
    ///
    /// This function verifies a digital signature provided by the Ed25519 algorithm for a given data and public key.
    ///
    /// - Parameters:
    ///    - data: The Data object to be verified.
    ///    - signature: The Signature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    ///
    /// - Throws: An error of type Ed25519Error.invalidSignature if the signature is invalid or an error occurred during verification.
    public func verify(data: Data, signature: Signature, _ privateKey: Data) throws -> Bool {
        return Ed25519.verify(
            signature: [UInt8](signature.signature),
            message: [UInt8](data),
            publicKey: [UInt8](self.key)
        )
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ED25519PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != ED25519PublicKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return try ED25519PublicKey(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
