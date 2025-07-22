//
//  Account.swift
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

/// Sui Blockchain Account
public struct Account: Equatable, Hashable {
    /// Represents the type of cryptographic key associated with the account.
    /// For example, it could be `ed25519`, `secp256k1`, or `secp256r1`.
    public let accountType: KeyType

    /// Represents the public key associated with the account. The public key is used
    /// to verify signatures created using the corresponding private key and to derive the blockchain address.
    public let publicKey: any PublicKeyProtocol

    /// Represents the private key associated with the account. The private key is used to
    /// create cryptographic signatures. It is kept private and should never be shared.
    private let privateKey: any PrivateKeyProtocol

    /// Creates an account with the given key type.
    ///
    /// - Parameter accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    /// - Throws: An error if the account initialization fails.
    public init(accountType: KeyType = .ed25519, hasBiometrics: Bool = false) throws {
        switch accountType {
        case .ed25519:
            let privateKey = ED25519PrivateKey()
            try self.init(privateKey: privateKey, accountType: accountType)
        case .secp256k1:
            let privateKey = try SECP256K1PrivateKey()
            try self.init(privateKey: privateKey, accountType: accountType)
        case .secp256r1:
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                let privateKey = try SECP256R1PrivateKey(hasBiometrics: hasBiometrics)
                try self.init(privateKey: privateKey, accountType: accountType)
            } else {
                throw AccountError.incompatibleOS
            }
        }
    }

    /// Creates an account with the given private key and key type.
    ///
    /// - Parameters:
    ///   - privateKey: The private key data.
    ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    /// - Throws: An error if the account initialization fails.
    public init(
        privateKey: Data,
        accountType: KeyType = .ed25519
    ) throws {
        switch accountType {
        case .ed25519:
            let privateKey = try ED25519PrivateKey(key: privateKey)
            try self.init(privateKey: privateKey, accountType: accountType)
        case .secp256k1:
            let privateKey = try SECP256K1PrivateKey(key: privateKey)
            try self.init(privateKey: privateKey, accountType: accountType)
        case .secp256r1:
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                let privateKey = try SECP256R1PrivateKey(key: privateKey)
                try self.init(privateKey: privateKey, accountType: accountType)
            } else {
                throw AccountError.incompatibleOS
            }
        }
    }

    /// Creates an account with the given public key, private key, and key type.
    ///
    /// - Parameters:
    ///   - publicKey: The public key protocol.
    ///   - privateKey: The private key protocol.
    ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    public init(
        publicKey: any PublicKeyProtocol,
        privateKey: any PrivateKeyProtocol,
        accountType: KeyType = .ed25519
    ) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.accountType = accountType
    }

    /// Creates an account with the given private key protocol and key type.
    ///
    /// - Parameters:
    ///   - privateKey: The private key protocol.
    ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    /// - Throws: An error if the public key initialization fails.
    public init(
        privateKey: any PrivateKeyProtocol,
        accountType: KeyType = .ed25519
    ) throws {
        self.privateKey = privateKey
        self.publicKey = try privateKey.publicKey()
        self.accountType = accountType
    }

    /// Creates an account with the given key type and hexadecimal string representation of the private key.
    ///
    /// - Parameters:
    ///   - keyType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    ///   - hexString: The hexadecimal string representation of the private key.
    /// - Throws: An error if the account initialization fails.
    public init(
        keyType: KeyType = .ed25519,
        hexString: String
    ) throws {
        switch keyType {
        case .ed25519:
            let privateKey = ED25519PrivateKey(hexString: hexString)
            self.privateKey = privateKey
            self.publicKey = try privateKey.publicKey()
            self.accountType = keyType
        case .secp256k1:
            let privateKey = SECP256K1PrivateKey(hexString: hexString)
            self.privateKey = privateKey
            self.publicKey = try privateKey.publicKey()
            self.accountType = keyType
        case .secp256r1:
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                let privateKey = try SECP256R1PrivateKey(hexString: hexString)
                self.privateKey = privateKey
                self.publicKey = try privateKey.publicKey()
                self.accountType = keyType
            } else {
                throw AccountError.incompatibleOS
            }
        }
    }

    /// Creates an account from the JSON representation of the private key stored at the given file path.
    ///
    /// - Parameters:
    ///   - keyType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    ///   - path: The file path to the JSON representation of the private key.
    /// - Throws: `SuiError.invalidJsonData` if the data is not a valid JSON,
    ///           or `SuiError.missingPrivateKey` if the private key is missing in the JSON data.
    public init(keyType: KeyType = .ed25519, path: String) throws {
        let fileURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: fileURL)
        guard let json = try JSONSerialization
            .jsonObject(with: data, options: []) as? [String: Any]
        else {
            throw SuiError.customError(message: "Invalid JSON data")
        }

        guard let privateKeyHex = json["private_key"] as? String else {
            throw SuiError.customError(message: "Missing Private Key")
        }

        try self.init(
            keyType: keyType,
            hexString: privateKeyHex
        )
    }

    /// Creates an account with the given mnemonic and key type.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic phrase.
    ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    /// - Throws: An error if the account initialization fails.
    public init(_ mnemonic: String, accountType: KeyType = .ed25519) throws {
        self.accountType = accountType

        switch accountType {
        case .ed25519:
            let privateKey = try ED25519PrivateKey(mnemonic)
            self.privateKey = privateKey
            self.publicKey = try privateKey.publicKey()
        case .secp256k1:
            let privateKey = try SECP256K1PrivateKey(mnemonic)
            self.privateKey = privateKey
            self.publicKey = try privateKey.publicKey()
        case .secp256r1:
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                let privateKey = try SECP256R1PrivateKey(mnemonic)
                self.privateKey = privateKey
                self.publicKey = try privateKey.publicKey()
            } else {
                throw AccountError.incompatibleOS
            }
        }
    }

    /// Creates an account with the given value and key type.
    ///
    /// - Parameters:
    ///   - accountType: The type of cryptographic key to be used. Defaults to `.ed25519`.
    ///   - value: A string value representing the private key.
    /// - Throws: An error if the account initialization fails.
    public init(accountType: KeyType = .ed25519, _ value: String) throws {
        self.accountType = accountType

        switch accountType {
        case .ed25519:
            let privateKey = try ED25519PrivateKey(value: value)
            self.privateKey = privateKey
            self.publicKey = try privateKey.publicKey()
        case .secp256k1:
            let privateKey = try SECP256K1PrivateKey(value: value)
            self.privateKey = privateKey
            self.publicKey = try privateKey.publicKey()
        case .secp256r1:
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                let privateKey = try SECP256R1PrivateKey(value: value)
                self.privateKey = privateKey
                self.publicKey = try privateKey.publicKey()
            } else {
                throw AccountError.incompatibleOS
            }
        }
    }

    public static func == (lhs: Account, rhs: Account) -> Bool {
        if
            lhs.privateKey.key.getType() == rhs.privateKey.key.getType() &&
            lhs.publicKey.key.getType() == rhs.publicKey.key.getType() {
            if lhs.privateKey.key.getType() == .data {
                return
                    (lhs.privateKey.key as! Data) == (rhs.privateKey.key as! Data) &&
                    (lhs.publicKey.key as! Data) == (rhs.publicKey.key as! Data)
            }
            if lhs.privateKey.key.getType() == .p256 {
                return
                    (lhs.privateKey.key as! SecureEnclave.P256.Signing.PrivateKey) == (rhs.privateKey.key as! SecureEnclave.P256.Signing.PrivateKey) &&
                    (lhs.publicKey.key as! P256.Signing.PublicKey) == (rhs.publicKey.key as! P256.Signing.PublicKey)
            }
        }
        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.privateKey.base64())
        hasher.combine(self.publicKey.base64())
    }

    // TODO: Implement Available tag for MacOS machines only
    /// Store the account information to a file at the given path.
    ///
    /// This function takes a path as a string and stores the account information in a JSON file
    /// with keys for the account address and the private key in hex format.
    ///
    /// - Parameters:
    ///    - path: A string representing the file path to store the account information.
    ///
    /// - Throws: An error of type SuiError if there is an issue writing to the file.
    public func store(_ path: String) throws {
        let data: [String: String] = [
            "account_address": self.publicKey.hex(),
            "private_key": self.privateKey.hex()
        ]

        let fileURL = URL(fileURLWithPath: path)
        let jsonData = try JSONSerialization
            .data(withJSONObject: data, options: [])

        try jsonData.write(to: fileURL)
    }

    /// Returns the account's account address.
    /// - Returns: An AccountAddress object
    public func address() throws -> String {
        return try self.publicKey.toSuiAddress()
    }

    /// Use the private key to sign the data inputted.
    /// - Parameter data: The data being serialized / signed
    /// - Returns: A Signature object
    public func sign(_ data: Data) throws -> Signature {
        return try self.privateKey.sign(data: data)
    }

    /// Verifies the given signature with the given data using the public key.
    ///
    /// - Parameters:
    ///   - data: The data that was signed.
    ///   - signature: The signature to verify.
    /// - Returns: A boolean value indicating whether the signature is valid.
    /// - Throws: An error if the verification process fails.
    public func verify(
        _ data: Data,
        _ signature: Signature
    ) throws -> Bool {
        return try self.publicKey.verify(
            data: data,
            signature: signature
        )
    }

    /// Signs the given bytes with a specified intent using the private key.
    ///
    /// - Parameters:
    ///   - bytes: The data to sign.
    ///   - intent: The intent scope of the signing.
    /// - Returns: The resulting signature.
    /// - Throws: An error if the signing process fails.
    public func signWithIntent(
        _ bytes: [UInt8],
        _ intent: IntentScope
    ) throws -> Signature {
        return try self.privateKey.signWithIntent(bytes, intent)
    }

    /// Signs the transaction block using the private key.
    ///
    /// - Parameters:
    ///   - bytes: The transaction block to sign.
    /// - Returns: The resulting signature.
    /// - Throws: An error if the signing process fails.
    public func signTransactionBlock(
        _ bytes: [UInt8]
    ) throws -> Signature {
        return try self.privateKey.signTransactionBlock(bytes)
    }

    /// Signs a personal message using the private key.
    ///
    /// - Parameters:
    ///   - bytes: The personal message to sign.
    /// - Returns: The resulting signature.
    /// - Throws: An error if the signing process fails.
    public func signPersonalMessage(
        _ bytes: [UInt8]
    ) throws -> Signature {
        return try self.privateKey.signPersonalMessage(bytes)
    }

    /// Verifies the signature of a transaction block using the public key.
    ///
    /// - Parameters:
    ///   - transactionBlock: The transaction block that was signed.
    ///   - signature: The signature to verify.
    /// - Returns: A boolean value indicating whether the signature is valid.
    /// - Throws: An error if the verification process fails.
    public func verifyTransactionBlock(
        _ transactionBlock: [UInt8],
        _ signature: Signature
    ) throws -> Bool {
        return try self.publicKey.verifyTransactionBlock(
            transactionBlock, signature
        )
    }

    /// Verifies the signature of the given bytes with a specified intent using the public key.
    ///
    /// - Parameters:
    ///   - bytes: The data that was signed.
    ///   - signature: The signature to verify.
    ///   - intent: The intent scope of the verification.
    /// - Returns: A boolean value indicating whether the signature is valid.
    /// - Throws: An error if the verification process fails.
    public func verifyWithIntent(
        _ bytes: [UInt8],
        _ signature: Signature,
        _ intent: IntentScope
    ) throws -> Bool {
        return try self.publicKey.verifyWithIntent(
            bytes,
            signature,
            intent
        )
    }

    /// Verifies the signature of a personal message using the public key.
    ///
    /// - Parameters:
    ///   - message: The personal message that was signed.
    ///   - signature: The signature to verify.
    /// - Returns: A boolean value indicating whether the signature is valid.
    /// - Throws: An error if the verification process fails.
    public func verifyPersonalMessage(
        _ message: [UInt8],
        _ signature: Signature
    ) throws -> Bool {
        return try self.publicKey.verifyPersonalMessage(
            message,
            signature
        )
    }

    /// Serializes the given signature to a string.
    ///
    /// - Parameter signature: The signature to serialize.
    /// - Returns: The serialized signature as a string.
    /// - Throws: An error if the serialization process fails.
    public func toSerializedSignature(_ signature: Signature) throws -> String {
        return try self.publicKey.toSerializedSignature(
            signature: signature
        )
    }

    /// Exports the account to an `ExportedAccount` representation.
    ///
    /// - Returns: The exported account representation.
    /// - Throws: `AccountError.cannotBeExported` if the account's private key type is unsupported for export.
    public func export() throws -> ExportedAccount {
        if self.privateKey.key.getType() == .data {
            return ExportedAccount(
                schema: self.accountType,
                privateKey: (privateKey.key as! Data).base64EncodedString()
            )
        }
        if self.privateKey.key.getType() == .p256 {
            return ExportedAccount(
                schema: self.accountType,
                privateKey: "\((privateKey.key as! SecureEnclave.P256.Signing.PrivateKey).rawRepresentation.base64EncodedString())"
            )
        }
        throw AccountError.cannotBeExported
    }
}
