//
//  PrivateKeyProtocol.swift
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

/// Protocol defining the requirements for a private key type.
public protocol PrivateKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    /// The type of the public key that corresponds to this private key.
    associatedtype PublicKeyType: PublicKeyProtocol

    /// The type of data value that represents the key.
    associatedtype DataValue: KeyValueProtocol

    /// The actual private key data.
    var key: DataValue { get }

    /// Returns the hexadecimal representation of the private key.
    func hex() -> String

    /// Returns the base64 representation of the private key.
    func base64() -> String

    /// Computes and returns the corresponding public key.
    /// Throws an error if the operation fails.
    func publicKey() throws -> PublicKeyType

    /// Signs the given data and returns the signature.
    /// Throws an error if the signing operation fails.
    func sign(data: Data) throws -> Signature

    /// Signs the given bytes with a specific intent.
    /// Throws an error if the signing operation fails.
    func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature

    /// Signs a transaction block represented by the given bytes.
    /// Throws an error if the signing operation fails.
    func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature

    /// Signs a personal message represented by the given bytes.
    /// Throws an error if the signing operation fails.
    func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature
}
