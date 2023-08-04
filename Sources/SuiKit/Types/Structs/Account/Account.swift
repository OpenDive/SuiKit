//
//  Account.swift
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
import Bip39

/// Sui Blockchain Account
public struct Account: Equatable, Hashable {
    public let accountType: KeyType
    
    /// The public key associated with the account
    public let publicKey: any PublicKeyProtocol

    /// The private key for the account
    private let privateKey: any PrivateKeyProtocol
    
    public init(accountType: KeyType = .ed25519) throws {
        switch accountType {
        case .ed25519:
            let privateKey = ED25519PrivateKey()
            try self.init(privateKey: privateKey, accountType: accountType)
        case .secp256k1:
            let privateKey = try SECP256K1PrivateKey()
            try self.init(privateKey: privateKey, accountType: accountType)
        }
    }
    
    public init(privateKey: Data, accountType: KeyType = .ed25519) throws {
        switch accountType {
        case .ed25519:
            let privateKey = ED25519PrivateKey(key: privateKey)
            try self.init(privateKey: privateKey, accountType: accountType)
        case .secp256k1:
            let privateKey = SECP256K1PrivateKey(key: privateKey)
            try self.init(privateKey: privateKey, accountType: accountType)
        }
    }
    
    public init(publicKey: any PublicKeyProtocol, privateKey: any PrivateKeyProtocol, accountType: KeyType = .ed25519) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.accountType = accountType
    }
    
    public init(privateKey: any PrivateKeyProtocol, accountType: KeyType = .ed25519) throws {
        self.privateKey = privateKey
        self.publicKey = try privateKey.publicKey()
        self.accountType = accountType
    }
    
    public init(keyType: KeyType = .ed25519, hexString: String) throws {
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
        }
    }
    
    public init(keyType: KeyType = .ed25519, path: String) throws {
        let fileURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: fileURL)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw SuiError.invalidJsonData
        }

        guard let privateKeyHex = json["private_key"] as? String else {
            throw SuiError.missingPrivateKey
        }

        try self.init(
            keyType: keyType,
            hexString: privateKeyHex
        )
    }
    
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
        }
    }

    public static func == (lhs: Account, rhs: Account) -> Bool {
        return
            lhs.publicKey.key == rhs.publicKey.key &&
            lhs.privateKey.key == rhs.privateKey.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.privateKey.base64())
        hasher.combine(self.publicKey.base64())
    }

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
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
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
    
    public func verify(_ data: Data, _ signature: Signature) throws -> Bool {
        return try self.publicKey.verify(data: data, signature: signature)
    }
    
    func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature {
        return try self.privateKey.signWithIntent(bytes, intent)
    }
    
    func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature {
        return try self.privateKey.signTransactionBlock(bytes)
    }
    
    func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature {
        return try self.privateKey.signPersonalMessage(bytes)
    }
    
    func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool {
        return try self.publicKey.verifyTransactionBlock(transactionBlock, signature)
    }
    
    func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool {
        return try self.publicKey.verifyWithIntent(bytes, signature, intent)
    }
    
    func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool {
        return try self.publicKey.verifyPersonalMessage(message, signature)
    }
    
    public func export() -> ExportedAccount {
        return ExportedAccount(
            schema: self.accountType,
            privateKey: privateKey.key.base64EncodedString()
        )
    }
}

public struct ExportedAccount {
    public let schema: KeyType
    public let privateKey: String
    
    public init(schema: KeyType, privateKey: String) {
        self.schema = schema
        self.privateKey = privateKey
    }
}
