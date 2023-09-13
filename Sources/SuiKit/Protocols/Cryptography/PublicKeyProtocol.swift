//
//  PublicKeyProtocol.swift
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

/// Protocol defining the requirements for a public key type.
public protocol PublicKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    /// The type of data value that represents the key.
    associatedtype DataValue: KeyValueProtocol

    /// The actual public key data.
    var key: DataValue { get }

    /// Verifies the given data against a signature.
    /// Returns true if the signature is valid, false otherwise.
    /// Throws an error if the verification operation fails.
    func verify(data: Data, signature: Signature) throws -> Bool

    /// Returns the base64 representation of the public key.
    func base64() -> String

    /// Returns the hexadecimal representation of the public key.
    func hex() -> String

    /// Converts the public key to a Sui Address representation.
    /// Throws an error if the conversion fails.
    func toSuiAddress() throws -> String

    /// Verifies a transaction block using the given signature.
    /// Throws an error if the verification operation fails.
    func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool

    /// Verifies the given bytes with a specific intent and signature.
    /// Throws an error if the verification operation fails.
    func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool

    /// Verifies a personal message using the given signature.
    /// Throws an error if the verification operation fails.
    func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool

    /// Serializes a signature to its string representation.
    /// Throws an error if the serialization fails.
    func toSerializedSignature(signature: Signature) throws -> String
}
