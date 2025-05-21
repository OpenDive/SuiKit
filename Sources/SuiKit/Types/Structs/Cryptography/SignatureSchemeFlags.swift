//
//  SignatureSchemeFlags.swift
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

/// A structure representing mappings between signature scheme names and their corresponding flags.
public struct SignatureSchemeFlags {
    /// A dictionary mapping the names of signature schemes to their associated flags.
    nonisolated(unsafe) public static var SIGNATURE_SCHEME_TO_FLAG: [String: UInt8] = [
        "ED25519": 0x00,   // Represents the Ed25519 signature scheme.
        "SECP256K1": 0x01,  // Represents the SECP256K1 signature scheme.
        "SECP256R1": 0x02,  // Represents the SECP256R1 (P256) signature scheme.
        "zkLogin": 0x05  // Represents the zkLogin signature scheme.
    ]

    /// A dictionary mapping the flags of signature schemes to their associated names.
    nonisolated(unsafe) public static var SIGNATURE_FLAG_TO_SCHEME: [UInt8: String] = [
        0x00: "ED25519",   // Represents the flag for the Ed25519 signature scheme.
        0x01: "SECP256K1",  // Represents the flag for the SECP256K1 signature scheme.
        0x02: "SECP256R1",  // Represents the flag for the SECP256R1 (P256) signature scheme.
        0x05: "zkLogin"  // Represents the flag for the zkLogin signature scheme.
    ]
}
