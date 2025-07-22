//
//  SecurezkLoginStorage.swift
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
import Security

/// Protocol for secure storage of zkLogin related data
public protocol ZkLoginSecureStorage {
    /// Store an ephemeral private key securely
    func storeEphemeralKey(_ key: Data, forUser userId: String) throws

    /// Retrieve an ephemeral private key
    func retrieveEphemeralKey(forUser userId: String) throws -> Data

    /// Store a salt value securely
    func storeSalt(_ salt: String, forUser userId: String) throws

    /// Retrieve a salt value
    func retrieveSalt(forUser userId: String) throws -> String

    /// Delete all stored data for a user
    func clearUserData(forUser userId: String) throws
}

/// Default implementation of ZkLoginSecureStorage using Apple's Keychain
public class SecureZkLoginStorage: ZkLoginSecureStorage {
    private let keychainService: String

    /// Initialize with a keychain service identifier
    /// - Parameter service: The service identifier for keychain items
    public init(service: String = "com.opendive.suikit.zklogin") {
        self.keychainService = service
    }

    /// Store an ephemeral private key in the keychain
    /// - Parameters:
    ///   - key: The private key data
    ///   - userId: The user identifier
    public func storeEphemeralKey(_ key: Data, forUser userId: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(userId).ephemeral_key",
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: "\(userId).ephemeral_key"
            ]

            let updateAttributes: [String: Any] = [
                kSecValueData as String: key
            ]

            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)

            guard updateStatus == errSecSuccess else {
                throw SuiError.error(code: .keyChainError)
            }
        } else if status != errSecSuccess {
            throw SuiError.error(code: .keyChainError)
        }
    }

    /// Retrieve an ephemeral private key from the keychain
    /// - Parameter userId: The user identifier
    /// - Returns: The private key data
    public func retrieveEphemeralKey(forUser userId: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(userId).ephemeral_key",
            kSecReturnData as String: true
        ]

        var keyData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &keyData)

        guard status == errSecSuccess else {
            throw SuiError.error(code: .keyChainError)
        }

        guard let keyData = keyData as? Data else {
            throw SuiError.error(code: .missingKeyItem)
        }

        return keyData
    }

    /// Store a salt value in the keychain
    /// - Parameters:
    ///   - salt: The salt string
    ///   - userId: The user identifier
    public func storeSalt(_ salt: String, forUser userId: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(userId).salt",
            kSecValueData as String: Data(salt.utf8)
        ]

        // First delete any existing salt
        SecItemDelete(query as CFDictionary)

        // Add the new salt
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw SuiError.error(code: .keyChainError)
        }
    }

    /// Retrieve a salt value from the keychain
    /// - Parameter userId: The user identifier
    /// - Returns: The salt string
    public func retrieveSalt(forUser userId: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(userId).salt",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let saltData = item as? Data else {
            throw SuiError.error(code: .keyChainError)
        }

        guard let saltString = String(data: saltData, encoding: .utf8) else {
            throw SuiError.error(code: .dataEncodingFailed)
        }

        return saltString
    }

    /// Delete all stored data for a user
    /// - Parameter userId: The user identifier
    public func clearUserData(forUser userId: String) throws {
        // Delete ephemeral key
        let keyQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(userId).ephemeral_key"
        ]

        SecItemDelete(keyQuery as CFDictionary)

        // Delete salt
        let saltQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(userId).salt"
        ]

        SecItemDelete(saltQuery as CFDictionary)
    }

    // MARK: - Private helper functions

    /// Generate a unique tag for the key based on the service name and user ID
    /// - Parameter userId: The user identifier
    /// - Returns: A Data object containing the tag
    private func keyTag(forUser userId: String) -> Data {
        return "\(keychainService).\(userId)".data(using: .utf8)!
    }
}
