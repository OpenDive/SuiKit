//
//  PrivateKeyProtocol.swift
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

/// Protocol defining the requirements for a private key type.
public protocol PrivateKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    /// The type of the public key that corresponds to this private key.
    associatedtype PublicKeyType: PublicKeyProtocol

    /// The type of data value that represents the key.
    associatedtype DataValue: KeyValueProtocol

    /// The actual private key data.
    var key: DataValue { get }

    /// Converts the private key to a hexadecimal string.
    /// - Returns: A string representation of the private key in hexadecimal format, with a "0x" prefix.
    /// - Note: The hexEncodedString function of the Data type is called to convert the private key into a hexadecimal string, and "0x" is prepended to the resulting string.
    func hex() -> String

    /// Returns the base64 encoded string representation of the private key.
    /// - Returns: A `String` representing the base64 value itself.
    func base64() -> String

    /// Calculates the corresponding public key for this private key instance using the key's corresponding algorithm.
    /// - Returns: A PublicKey instance representing the public key associated with this private key.
    /// - Throws: An error if the calculation of the public key fails, or if the public key cannot be used to create a PublicKey instance.
    func publicKey() throws -> PublicKeyType

    /// Signs a message using this private key and the key's corresponding algorithm.
    /// - Parameter data: The message to be signed.
    /// - Returns: A Signature instance representing the signature for the message.
    /// - Throws: An error if the signing operation fails or if the resulting signature cannot be used to create a Signature instance.
    func sign(data: Data) throws -> Signature

    /// Signs the input bytes with the specified intent.
    /// - Parameters:
    ///   - bytes: The input bytes to sign.
    ///   - intent: The intended scope of the signature.
    /// - Throws: An error if the signing operation fails.
    /// - Returns: A `Signature` object representing the digital signature.
    func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature

    /// Signs the transaction block with the specified bytes.
    /// - Parameters:
    ///   - bytes: The input bytes of the transaction block to sign.
    /// - Throws: An error if the signing operation fails.
    /// - Returns: A `Signature` object representing the digital signature of the transaction block.
    func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature

    /// Signs a personal message with the specified bytes.
    /// - Parameters:
    ///   - bytes: The input bytes of the personal message to sign.
    /// - Throws: An error if the signing operation fails.
    /// - Returns: A `Signature` object representing the digital signature of the personal message.
    func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature
}
