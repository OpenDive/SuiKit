//
//  AccountError.swift
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

/// `AccountError` represents a set of errors that can occur while dealing with accounts, keys, or cryptographic operations.
public enum AccountError: Error, Equatable {
    /// Indicates that the provided public key is invalid.
    case invalidPublicKey

    /// Indicates that there is a mismatch in the expected length for certain data.
    case lengthMismatch

    /// Indicates that the length of the provided data is invalid.
    case invalidLength

    /// Indicates that the provided signature is invalid.
    case invalidSignature

    /// Indicates that the serialized signature is invalid.
    case invalidSerializedSignature

    /// Indicates that the parsed signature is invalid.
    case invalidParsedSignature

    /// Indicates that the parsed public key is invalid.
    case invalidParsedPublicKey

    /// Indicates that the provided data is invalid.
    case invalidData

    /// Indicates that the provided context for the operation is invalid.
    case invalidContext

    /// Indicates that the public key could not be created.
    case invalidPubKeyCreation

    /// Indicates that the generated key is invalid.
    case invalidGeneratedKey

    /// Indicates that the provided derivation path is invalid.
    case invalidDerivationPath

    /// Indicates that the provided mnemonic seed is invalid.
    case invalidMnemonicSeed

    /// Indicates that the HD (Hierarchical Deterministic) node is invalid.
    case invalidHDNode

    /// Indicates that the hardened path provided is invalid.
    case invalidHardenedPath

    /// Indicates that the curve data is invalid.
    case invalidCurveData

    /// Indicates that the number of keys is out of the allowable range. Takes minimum and maximum allowed values as associated values.
    case keysCountOutOfRange(min: Int, max: Int)

    /// Indicates that the threshold value is out of the allowable range. Takes minimum and maximum allowed values as associated values.
    case thresholdOutOfRange(min: Int, max: Int)

    /// Indicates that there is no content present in the key.
    case noContentInKey

    /// Indicates that the operation failed due to some unspecified data issue.
    case failedData

    /// Indicates that the data cannot be deserialized.
    case cannotBeDeserialized

    /// Indicates that the data cannot be serialized.
    case cannotBeSerialized

    /// Indicates that the data or key cannot be exported.
    case cannotBeExported

    case incompatibleOS

    case keychainReadFail(message: String)
}
