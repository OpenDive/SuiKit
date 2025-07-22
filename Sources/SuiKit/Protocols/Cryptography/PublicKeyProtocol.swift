//
//  PublicKeyProtocol.swift
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

/// Protocol defining the requirements for a public key type.
public protocol PublicKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    /// The type of data value that represents the key.
    associatedtype DataValue: KeyValueProtocol

    /// The actual public key data.
    var key: DataValue { get }

    /// Returns the base64 encoded string representation of the private key.
    /// - Returns: A `String` representing the base64 value itself.
    func base64() -> String

    /// Converts the private key to a hexadecimal string.
    /// - Returns: A string representation of the private key in hexadecimal format, with a "0x" prefix.
    /// - Note: The hexEncodedString function of the Data type is called to convert the private key into a hexadecimal string, and "0x" is prepended to the resulting string.
    func hex() -> String

    /// Verify a digital signature for a given data using the key's corresponding algorithm.
    ///
    /// This function verifies a digital signature provided by the key's corresponding algorithm for a given data and public key.
    /// - Parameters:
    ///    - data: The Data object to be verified.
    ///    - signature: The Signature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    /// - Throws: An error of type invalidSignature if the signature is invalid or an error occurred during verification.
    func verify(data: Data, signature: Signature) throws -> Bool

    /// Converts the public key to a Sui address.
    /// - Throws: If any error occurs during conversion.
    /// - Returns: A string representing the Sui address.
    func toSuiAddress() throws -> String

    /// Serializes the signature along with the public key.
    /// - Parameter signature: The signature to serialize.
    /// - Throws: If any error occurs during serialization.
    /// - Returns: A base64-encoded string representing the serialized signature.
    func toSerializedSignature(signature: Signature) throws -> String

    /// Verifies a transaction block with the given signature.
    /// - Parameters:
    ///   - transactionBlock: The transaction block to verify.
    ///   - signature: The signature to verify the block with.
    /// - Throws: If any error occurs during verification.
    /// - Returns: `true` if the verification is successful, otherwise `false`.
    func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool

    /// Verifies bytes with the given signature and intent.
    /// - Parameters:
    ///   - bytes: The bytes to verify.
    ///   - signature: The signature to verify the bytes with.
    ///   - intent: The intent scope of the verification.
    /// - Throws: If any error occurs during verification.
    /// - Returns: `true` if the verification is successful, otherwise `false`.
    func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool

    /// Verifies a personal message with the given signature.
    /// - Parameters:
    ///   - message: The personal message to verify.
    ///   - signature: The signature to verify the message with.
    /// - Throws: If any error occurs during verification.
    /// - Returns: `true` if the verification is successful, otherwise `false`.
    func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool

    func toSuiBytes() throws -> [UInt8]
}
