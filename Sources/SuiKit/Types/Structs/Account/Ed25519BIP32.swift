//
//  Ed25519BIP32.swift
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
import CryptoSwift

/// Used for deriving Seed Phrases for the HDWallet
public struct Ed25519BIP32 {
    private static let curve: String = "ed25519 seed"
    private let hardendedOffset: UInt = 0x80000000
    private var _masterKey: Data
    private var _chainCode: Data

    public init(seed: Data) {
        (_masterKey, _chainCode) = Ed25519BIP32.getMasterKeyFromSeed(seed)
    }

    /// Derive a hierarchical deterministic key and chain code from a derivation path string following the BIP32 standard.
    ///
    /// - Parameter path: A string representing the derivation path to use for the key derivation.
    /// - Returns: A tuple containing the derived key and chain code.
    /// - Throws: An SuiError object with the type invalidDerivationPath if the derivation path provided is invalid.
    public func derivePath(path: String) throws -> (key: Data, chainCode: Data) {
        if !Ed25519BIP32.isValidPath(path: path) {
            throw SuiError.invalidDerivationPath
        }

        let hardenedOffset: UInt32 = 0x80000000
        let segments = path.split(separator: "/").dropFirst().map { component -> UInt32 in
            return UInt32(component.replacingOccurrences(of: "'", with: ""))! + hardenedOffset
        }

        var results = (_masterKey, _chainCode)

        for next in segments {
            results = Ed25519BIP32.getChildKeyDerivation(key: results.0, chainCode: results.1, index: next)
        }

        return results
    }

    /// Derives a master key and chain code using the provided seed and returns them as a tuple.
    ///
    /// This function computes the master key and chain code using the provided seed according to the Ed25519
    /// BIP32 standard. It returns the master key and chain code as a tuple.
    ///
    /// - Parameters:
    ///    - seed: The seed value to use in deriving the master key and chain code.
    ///
    /// - Returns: A tuple of the master key and chain code, both as Data objects.
    private static func getMasterKeyFromSeed(_ seed: Data) -> (key: Data, chainCode: Data) {
        return hmacSha512(Ed25519BIP32.curve.data(using: .utf8)!, seed)
    }

    /// Derives the child key for a given index using a parent key and chain code.
    ///
    /// This function implements the key derivation function described in the BIP32 specification, which uses HMAC-SHA512
    /// to derive a child key from a parent key and chain code.
    ///
    /// - Parameters:
    ///    - key: The parent key data.
    ///    - chainCode: The parent chain code data.
    ///    - index: The index of the child key to derive.
    ///
    /// - Returns: A tuple containing the derived child key data and chain code data.
    private static func getChildKeyDerivation(key: Data, chainCode: Data, index: UInt32) -> (key: Data, chainCode: Data) {
        var buffer = Data()

        buffer.append(UInt8(0))
        buffer.append(key)
        let indexBytes = withUnsafeBytes(of: index.bigEndian) { Data($0) }
        buffer.append(indexBytes)

        return hmacSha512(chainCode, buffer)
    }

    /// Computes a Hash-based Message Authentication Code (HMAC) using the SHA-512 cryptographic hash function.
    ///
    /// - Parameters:
    ///    - keyBuffer: The secret key for the HMAC.
    ///    - data: The message to be authenticated.
    ///
    /// - Returns: A tuple containing two values: the first is the result of the HMAC operation (i.e. the derived key), and the second is the chaining value.
    private static func hmacSha512(_ keyBuffer: Data, _ data: Data) -> (key: Data, chainCode: Data) {
        do {
            let hmac = HMAC(key: keyBuffer.bytes, variant: .sha2(.sha512))
            let i = try hmac.authenticate(data.bytes)

            let il = Data(i[0..<32])
            let ir = Data(i[32...])

            return (key: il, chainCode: ir)
        } catch {
            return (key: Data(), chainCode: Data())
        }
    }

    /// Check if a given BIP32 derivation path is valid.
    ///
    /// This function validates a BIP32 derivation path using the regular expression ^m(\\/[0-9]+')+$.
    /// The path must start with m, followed by one or more numbers separated by slashes, and each number may
    /// be followed by an optional apostrophe. For example: m/44'/0'/0'/0/0.
    ///
    /// - Parameter path: The BIP32 derivation path to validate.
    ///
    /// - Returns: true if the path is valid, false otherwise.
    private static func isValidPath(path: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^m(\\/[0-9]+')+$")
        let range = NSRange(location: 0, length: path.utf16.count)

        if regex.firstMatch(in: path, options: [], range: range) == nil {
            return false
        }

        let components = path.split(separator: "/").dropFirst()
        let valid = components.allSatisfy { component in
            if let _ = UInt32(component.replacingOccurrences(of: "'", with: "")) {
                return true
            }
            return false
        }

        return valid
    }
}
