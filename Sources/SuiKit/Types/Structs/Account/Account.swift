//
//  Account.swift
//  AptosKit
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

/// Aptos Blockchain Account
public struct Account: Equatable {
    /// The account address associated with the account
    public let accountAddress: AccountAddress

    /// The private key for the account
    public let privateKey: ED25519PrivateKey

    public static func == (lhs: Account, rhs: Account) -> Bool {
        return
            lhs.accountAddress == rhs.accountAddress &&
            lhs.privateKey == rhs.privateKey
    }

    /// Generate a new account instance with a random private key.
    ///
    /// This function generates a new private key and derives the associated account address.
    /// A new account instance is created with the generated address and private key.
    ///
    /// - Throws: An error of type Error if there was a problem generating the private key or account address.
    ///
    /// - Returns: A new Account instance with a randomly generated private key and associated account address.
    public static func generate() throws -> Account {
        let privateKey = try ED25519PrivateKey.random()
        let accountAddress = try AccountAddress.fromKey(privateKey.publicKey())
        return Account(accountAddress: accountAddress, privateKey: privateKey)
    }

    /// Load an account from a private key in hex format.
    ///
    /// This function takes a private key in hex format and attempts to load it into an account by creating a PrivateKey instance from the hex string and then deriving an AccountAddress from the public key. A new Account instance is created using the derived AccountAddress and the PrivateKey.
    ///
    /// - Parameter key: A private key in hex format.
    ///
    /// - Throws: An error of type PrivateKeyError if the private key cannot be derived from the hex string, or AccountAddressError if the account address cannot be derived from the private key.
    ///
    /// - Returns: An Account instance containing the derived AccountAddress and PrivateKey.
    public static func loadKey(_ key: String) throws -> Account {
        let privateKey = ED25519PrivateKey.fromHex(key)
        let accountAddress = try AccountAddress.fromKey(privateKey.publicKey())
        return Account(accountAddress: accountAddress, privateKey: privateKey)
    }

    /// Load an account from a JSON file.
    ///
    /// This function loads an account object from a JSON file by reading the file content from the provided path, deserializing the JSON data,
    /// retrieving the account_address and private_key keys, and then constructing and returning an account object from them.
    ///
    /// - Parameters:
    ///    - path: A string representing the path to the JSON file.
    ///
    /// - Throws: An error of type SuiError if the JSON file is invalid, if the account_address key is missing, or if the private_key key is missing.
    ///
    /// - Returns: An account object constructed from the account_address and private_key keys in the JSON file.
    public static func load(_ path: String) throws -> Account {
        let fileURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: fileURL)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw SuiError.invalidJsonData
        }

        guard let accountAddressHex = json["account_address"] as? String else {
            throw SuiError.missingAccountAddressKey
        }
        guard let privateKeyHex = json["private_key"] as? String else {
            throw SuiError.missingPrivateKey
        }

        let accountAddress = try AccountAddress.fromHex(accountAddressHex)
        let privateKey = ED25519PrivateKey.fromHex(privateKeyHex)

        return Account(accountAddress: accountAddress, privateKey: privateKey)
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
            "account_address": self.accountAddress.hex(),
            "private_key": self.privateKey.hex()
        ]

        let fileURL = URL(fileURLWithPath: path)
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        try jsonData.write(to: fileURL)
    }
    
    /// Returns the account's account address.
    /// - Returns: An AccountAddress object
    public func address() -> AccountAddress {
        return self.accountAddress
    }
    
    /// Returns the hexadecimal representation of the authorization key for the account
    /// - Returns: A String object
    public func authKey() throws -> String {
        return try AccountAddress.fromKey(self.privateKey.publicKey()).hex()
    }

    /// Use the private key to sign the data inputted.
    /// - Parameter data: The data being serialized / signed
    /// - Returns: A Signature object
    public func sign(_ data: Data) throws -> Signature {
        return try self.privateKey.sign(data: data)
    }
    
    /// Returns the public key of the associated account
    /// - Returns: A PublicKey object
    public func publicKey() throws -> ED25519PublicKey {
        return try self.privateKey.publicKey()
    }
}
