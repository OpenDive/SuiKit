//
//  ED25519PrivateKey.swift
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
import ed25519swift
import CryptoSwift
import Bip39
import Blake2

/// Represents an ED25519 private key and provides functionality for signing and path derivation.
public struct ED25519PrivateKey: Equatable, PrivateKeyProtocol {
    public typealias DataValue = Data
    public typealias PublicKeyType = ED25519PublicKey

    /// Length of the private key.
    public static let LENGTH: Int = 32

    /// Offset used for creating hardened keys.
    public static let hardenedOffset: UInt32 = 0x80000000

    /// Regular expression used to validate derivation path.
    public static let pathRegex: String = "^m(\\/[0-9]+')+$"

    /// Identifier for the curve used with ED25519 private key.
    public static let curve: String = "ed25519 seed"

    /// Default derivation path for the private key.
    public static let defaultDerivationPath = "m/44'/784'/0'/0'/0'"

    /// Regular expression used to validate hardened derivation path.
    public static let hardenedPathRegex = "^m\\/44'\\/784'\\/[0-9]+'\\/[0-9]+'\\/[0-9]+'+$"

    public var key: DataValue

    public init(key: Data) throws {
        guard key.count == Self.LENGTH else {
            throw AccountError.invalidLength
        }
        self.key = key
    }

    public init(hexString: String) {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        self.key = Data(hex: hexValue)
    }

    public init() {
        let privateKeyArray = Ed25519.generateKeyPair().secretKey
        self.key = Data(privateKeyArray)
    }

    public init(_ mnemonic: String, _ path: String = ED25519PrivateKey.defaultDerivationPath) throws {
        guard ED25519PrivateKey.isValidHardenedPath(path: path) else { throw AccountError.invalidHardenedPath }
        let key = try ED25519PrivateKey.derivePath(path, mnemonic)
        self.key = key.key
    }

    public init(value: String) throws {
        guard let data = Data.fromBase64(value) else { throw AccountError.invalidData }
        self.key = data
    }

    public static func == (lhs: ED25519PrivateKey, rhs: ED25519PrivateKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return self.hex()
    }

    public func hex() -> String {
        return "0x\(self.key.hexEncodedString())"
    }

    public func base64() -> String {
        return self.key.base64EncodedString()
    }

    public func publicKey() throws -> PublicKeyType {
        let key = Ed25519.calcPublicKey(secretKey: [UInt8](self.key))
        return try ED25519PublicKey(data: Data(key))
    }

    public func sign(data: Data) throws -> Signature {
        let signedMessage = Ed25519.sign(message: [UInt8](data), secretKey: [UInt8](self.key))
        return Signature(
            signature: Data(signedMessage),
            publickey: try self.publicKey().key,
            signatureScheme: .ED25519
        )
    }

    public func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature {
        let intentMessage = RawSigner.messageWithIntent(intent, Data(bytes))
        let digest = try Blake2b.hash(size: 32, data: intentMessage)

        let signature = try self.sign(data: digest)
        return signature
    }

    public func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature {
        return try self.signWithIntent(bytes, .TransactionData)
    }

    public func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature {
        let ser = Serializer()
        try ser.sequence(bytes, Serializer.u8)
        return try self.signWithIntent([UInt8](ser.output()), .PersonalMessage)
    }

    /// Derives child keys from the given path and mnemonic.
    /// - Parameters:
    ///   - path: The derivation path.
    ///   - mnemonic: The mnemonic phrase used to generate the seed.
    ///   - offset: The offset used for creating hardened keys.
    /// - Throws: An error if derivation fails due to invalid path, curve data, or other reasons.
    /// - Returns: The derived keys.
    private static func derivePath(
        _ path: String,
        _ mnemonic: String,
        _ offset: UInt32 = ED25519PrivateKey.hardenedOffset
    ) throws -> Keys {
        guard ED25519PrivateKey.isValidPath(path) else { throw AccountError.invalidDerivationPath }

        let segments = path.split(separator: "/").dropFirst().map { component -> UInt32 in
            return UInt32(component.replacingOccurrences(of: "'", with: ""))! + offset
        }

        guard let curveData = ED25519PrivateKey.curve.data(using: .utf8) else { throw AccountError.invalidCurveData }
        let seedData = try ED25519PrivateKey.seed(mnemonic)

        var result = try self.hmacSha512(curveData, seedData)

        for next in segments {
            result = try self.getChildKeyDerivation(key: result.key, chainCode: result.chainCode, index: next)
        }

        return result
    }

    /// Gets child key derivation using key, chain code, and index.
    /// - Parameters:
    ///   - key: The key data.
    ///   - chainCode: The chain code.
    ///   - index: The index.
    /// - Throws: An error if the child key derivation fails.
    /// - Returns: The derived keys.
    private static func getChildKeyDerivation(key: Data, chainCode: Data, index: UInt32) throws -> Keys {
        var buffer = Data()

        buffer.append(UInt8(0))
        buffer.append(key)
        let indexBytes = withUnsafeBytes(of: index.bigEndian) { Data($0) }
        buffer.append(indexBytes)

        return try self.hmacSha512(chainCode, buffer)
    }

    /// Performs HMAC-SHA512.
    /// - Parameters:
    ///   - keyBuffer: The key buffer.
    ///   - data: The data.
    /// - Throws: An error if HMAC-SHA512 authentication fails.
    /// - Returns: The derived keys.
    private static func hmacSha512(_ keyBuffer: Data, _ data: Data) throws -> Keys {
        let hmac = HMAC(key: keyBuffer.bytes, variant: .sha2(.sha512))
        let i = try hmac.authenticate(data.bytes)

        let il = Data(i[0..<32])
        let ir = Data(i[32...])
        return Keys(key: il, chainCode: ir)
    }

    /// Validates the derivation path.
    /// - Parameter path: The derivation path.
    /// - Returns: A boolean value indicating whether the path is valid or not.
    private static func isValidPath(_ path: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: ED25519PrivateKey.pathRegex)

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

    /// Generates seed from mnemonic.
    /// - Parameter mnemonic: The mnemonic phrase.
    /// - Throws: An error if seed generation fails.
    /// - Returns: The generated seed as `Data`.
    private static func seed(_ mnemonic: String) throws -> Data {
        let mnemonicMapping = (mnemonic as NSString).decomposedStringWithCompatibilityMapping
        let salt = ("mnemonic" as NSString).decomposedStringWithCompatibilityMapping
        let pbkdf2 = try PKCS5.PBKDF2(
            password: mnemonicMapping.bytes,
            salt: salt.bytes,
            iterations: 2048,
            keyLength: 64,
            variant: .sha2(.sha512)
        ).calculate()
        return Data(pbkdf2)
    }

    /// Validates the hardened derivation path.
    /// - Parameter path: The hardened derivation path.
    /// - Returns: A boolean value indicating whether the hardened path is valid or not.
    private static func isValidHardenedPath(path: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: ED25519PrivateKey.hardenedPathRegex, options: [])

        let range = NSRange(location: 0, length: path.utf16.count)
        let match = regex.firstMatch(in: path, options: [], range: range)

        return match != nil
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ED25519PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != ED25519PrivateKey.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try ED25519PrivateKey(key: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
