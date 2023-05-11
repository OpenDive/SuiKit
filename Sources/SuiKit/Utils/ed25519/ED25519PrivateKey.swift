//
//  PrivateKey.swift
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

/// The ED25519 Private Key
public struct ED25519PrivateKey: Equatable, KeyProtocol, CustomStringConvertible {
    /// The length of the key in bytes
    public static let LENGTH: Int = 32

    /// The key itself
    public let key: Data

    public init(key: Data) {
        self.key = key
    }

    public static func == (lhs: ED25519PrivateKey, rhs: ED25519PrivateKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return self.hex()
    }

    /// Converts the private key to a hexadecimal string.
    ///
    /// - Returns: A string representation of the private key in hexadecimal format, with a "0x" prefix.
    ///
    /// - Note: The hexEncodedString function of the Data type is called to convert the private key into a hexadecimal string, and "0x" is prepended to the resulting string.
    public func hex() -> String {
        return "0x" + self.key.hexEncodedString()
    }

    /// Creates a PrivateKey instance from a hex string.
    ///
    /// - Parameter value: A string representing the private key in hexadecimal format.
    ///
    /// - Returns: A PrivateKey instance representing the private key.
    ///
    /// - Note: The input string can optionally start with "0x". The string is converted into a Data instance using the hex initializer, and then used to create a new PrivateKey instance.
    public static func fromHex(_ value: String) -> ED25519PrivateKey {
        var hexValue = value
        if value.hasPrefix("0x") {
            hexValue = String(value.dropFirst(2))
        }
        let hexData = Data(hex: hexValue)
        return ED25519PrivateKey(key: hexData)
    }

    /// Calculates the corresponding public key for this private key instance using the Ed25519 algorithm.
    ///
    /// - Returns: A PublicKey instance representing the public key associated with this private key.
    ///
    /// - Throws: An error if the calculation of the public key fails, or if the public key cannot be used to create a PublicKey instance.
    ///
    /// - Note: The private key is converted into a UInt8 array and passed to the calcPublicKey function of the Ed25519 implementation. The resulting public key is then used to create a new PublicKey instance.
    public func publicKey() throws -> ED25519PublicKey {
        let key = Ed25519.calcPublicKey(secretKey: [UInt8](self.key))
        return try ED25519PublicKey(data: Data(key))
    }

    /// Generates a new random private key using the Ed25519 algorithm.
    ///
    /// - Returns: A new PrivateKey instance with a randomly generated private key.
    ///
    /// - Throws: An error if the generation of the key pair fails or if the generated private key cannot be used to create a PrivateKey instance.
    ///
    /// - Note: The generateKeyPair function of the Ed25519 implementation is called to generate a new key pair, and the secret key is extracted and used to create a new PrivateKey instance.
    public static func random() throws -> ED25519PrivateKey {
        let privateKeyArray = Ed25519.generateKeyPair().secretKey
        return ED25519PrivateKey(key: Data(privateKeyArray))
    }

    /// Signs a message using this private key and the Ed25519 algorithm.
    ///
    /// - Parameter data: The message to be signed.
    ///
    /// - Returns: A Signature instance representing the signature for the message.
    ///
    /// - Throws: An error if the signing operation fails or if the resulting signature cannot be used to create a Signature instance.
    ///
    /// - Note: The input message is converted into a UInt8 array and passed to the sign function of the Ed25519 implementation along with the private key converted into a UInt8 array. The resulting signature is then used to create a new Signature instance.
    public func sign(data: Data) throws -> Signature {
        let signedMessage = Ed25519.sign(message: [UInt8](data), secretKey: [UInt8](self.key))
        return Signature(signature: Data(signedMessage), publickey: try self.publicKey().key)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ED25519PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != ED25519PrivateKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return ED25519PrivateKey(key: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
