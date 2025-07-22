//
//  SignatureScheme.swift
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

/// `SignatureScheme` represents the cryptographic algorithm used for creating digital signatures.
///
/// - `ED25519`: Represents the Ed25519 cryptographic algorithm.
/// - `SECP256K1`: Represents the SECP256K1 cryptographic algorithm.
/// - `SECP256R1`: Represents the SECP256R1 (P256) cryptographic algorithm.
public enum SignatureScheme: String {
    /// Represents the Ed25519 cryptographic algorithm.
    case ED25519

    /// Represents the SECP256K1 cryptographic algorithm.
    case SECP256K1

    /// Represents the SECP256R1 cryptographic algorithm.
    case SECP256R1

    /// Represents the zkLogin zero knowledge proof algorithm
    case zkLogin
}
