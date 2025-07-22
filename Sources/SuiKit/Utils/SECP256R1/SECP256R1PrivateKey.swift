//
//  SECP256R1PrivateKey.swift
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
import CryptoKit
import Blake2
import Bip39
import BigInt

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
import LocalAuthentication
#endif

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct SECP256R1PrivateKey: PrivateKeyProtocol {
    public static let LENGTH: Int = 32

    public static let defaultDerivationPath: String = "m/74'/784'/0'/0/0"

    public let key: SecureEnclave.P256.Signing.PrivateKey

    public typealias PublicKeyType = SECP256R1PublicKey

    public typealias DataValue = SecureEnclave.P256.Signing.PrivateKey

    public init(key: Data) throws {
        guard SecureEnclave.isAvailable else { throw AccountError.incompatibleOS }
        if let privateKey = try? SecureEnclave.P256.Signing.PrivateKey(rawRepresentation: key) {
            self.key = privateKey
        } else {
            throw AccountError.invalidData
        }
    }

    public init(hasBiometrics: Bool = false) throws {
        if hasBiometrics {
            #if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
            guard SecureEnclave.isAvailable else { throw AccountError.incompatibleOS }
            let authContext = LAContext()
            let accessControl = Self.getBioSecAccessControl()
            self.key = try SecureEnclave.P256.Signing.PrivateKey(accessControl: accessControl, authenticationContext: authContext)
            #else
            self.key = try SecureEnclave.P256.Signing.PrivateKey()
            #endif
        } else {
            self.key = try SecureEnclave.P256.Signing.PrivateKey()
        }
    }

    public init(_ mnemonics: String, _ path: String = SECP256R1PrivateKey.defaultDerivationPath) throws {
        guard SecureEnclave.isAvailable else { throw AccountError.incompatibleOS }
        guard SECP256R1PrivateKey.isValidBIP32Path(path) else { throw AccountError.invalidDerivationPath }
        let seedValue = try SECP256R1PrivateKey.mnemonicToSeed(mnemonics)
        if (seedValue.count * 8) < 128 || (seedValue.count * 8) > 512 { throw AccountError.invalidMnemonicSeed }
        guard let node = HDNode(seed: Data(seedValue))?.derive(path: path, derivePrivateKey: true), let privateKey = node.privateKey else {
            throw AccountError.invalidHDNode
        }
        try self.init(key: privateKey)
    }

    public init(value: String) throws {
        guard SecureEnclave.isAvailable else { throw AccountError.incompatibleOS }
        guard let data = Data.fromBase64(value) else { throw AccountError.invalidData }
        try self.init(key: data)
    }

    public init(hexString: String) throws {
        guard SecureEnclave.isAvailable else { throw AccountError.incompatibleOS }
        guard let data = hexString.data(using: .utf8) else { throw AccountError.invalidData }
        try self.init(key: data)
    }

    public init(account: String) throws {
        guard SecureEnclave.isAvailable else { throw AccountError.incompatibleOS }
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: account,
                     kSecUseDataProtectionKeychain: true,
                     kSecReturnData: true] as [String: Any]
        var item: CFTypeRef?
        switch SecItemCopyMatching(query as CFDictionary, &item) {
        case errSecSuccess:
            guard let data = item as? Data else { throw SuiError.notImplemented }
            self.key = try SecureEnclave.P256.Signing.PrivateKey(rawRepresentation: data)
        case errSecItemNotFound: throw SuiError.notImplemented
        case let status: throw AccountError.keychainReadFail(message: "\(status)")
        }
    }

    public var description: String {
        return self.hex()
    }

    public func publicKey() throws -> SECP256R1PublicKey {
        return SECP256R1PublicKey(key: self.key.publicKey)
    }

    public func hex() -> String {
        return "0x\(self.key.rawRepresentation.hexEncodedString())"
    }

    public func base64() -> String {
        return self.key.rawRepresentation.base64EncodedString()
    }

    public func sign(data: Data) throws -> Signature {
        let signature = try self.key.signature(for: data)
        return Signature(
            signature: self.normalizeSignature(signature.rawRepresentation.hexEncodedString()),
            publickey: try self.publicKey().key.compressedRepresentation,
            signatureScheme: .SECP256R1
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

    public func storeKey(account: String) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecUseDataProtectionKeychain: true,
            kSecValueData: self.key.rawRepresentation
        ] as [String: Any]

        // Add the key data.
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SuiError.notImplemented
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256R1PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256R1PrivateKey.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try SECP256R1PrivateKey(key: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key.rawRepresentation)
    }

    /// The BIP32 path is a string representation used to derive keys from a seed in a hierarchical manner.
    /// - Parameters:
    ///   - path: A string representing the BIP32 path.
    /// - Returns: A boolean value, `true` if the given path is valid, `false` otherwise.
    /// - Note: The pattern for a valid BIP32 path for this function is "^m\\/(54|74)'\\/784'\\/[0-9]+'\\/[0-9]+\\/[0-9]+$".
    private static func isValidBIP32Path(_ path: String) -> Bool {
        let pattern = "^m\\/(54|74)'\\/784'\\/[0-9]+'\\/[0-9]+\\/[0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex?.matches(in: path, options: [], range: NSRange(location: 0, length: path.utf16.count))

        return matches?.first != nil
    }

    /// Converts a mnemonic string to a seed. A mnemonic is a human-readable representation of a seed, typically
    /// consisting of a sequence of randomly chosen words. The seed is a byte array generated from the mnemonic and
    /// is used to derive cryptographic keys.
    /// - Parameters:
    ///   - mnemonics: A string of space-separated words representing the mnemonic.
    /// - Returns: An array of bytes representing the derived seed.
    /// - Throws: If there is an error during the conversion of the mnemonic to a seed, an error will be thrown.
    private static func mnemonicToSeed(_ mnemonics: String) throws -> [UInt8] {
        let mnemonic = try Mnemonic(mnemonic: mnemonics.components(separatedBy: " "))
        return mnemonic.seed()
    }

    /// Normalize the Signature to conform with the P256 signature standard.
    private func normalizeSignature(_ signatureHex: String) -> Data {
        let curveOrder = BigInt("FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551", radix: 16)!

        // Assuming the signature is evenly split between r and s
        let rHex = String(signatureHex.prefix(signatureHex.count / 2))
        let sHex = String(signatureHex.suffix(signatureHex.count / 2))

        // Convert hex to BigInt
        var s = BigInt(sHex, radix: 16)!

        // Normalize s if necessary
        let halfCurveOrder = curveOrder / 2
        if s > halfCurveOrder {
            s = curveOrder - s
        }

        // Convert back to hex, ensuring it's zero-padded to the correct length
        let normalizedSHex = String(s, radix: 16).leftPad(toLength: sHex.count, withPad: "0")
        let normalizedSignature = rHex + normalizedSHex
        return Data(hex: normalizedSignature)
    }

    /// Provide Biometric Access Control settings for the Secure Enclave key.
    private static func getBioSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?

        access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error
        )

        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access!
    }
}
