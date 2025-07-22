//
//  SecureZkLoginStorageTests.swift
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
import XCTest
@testable import SuiKit

final class SecureZkLoginStorageTests: XCTestCase {

    // Storage instance to use in tests
    var storage: SecureZkLoginStorage!

    override func setUp() {
        super.setUp()
        // Create instance with test-specific service name
        storage = SecureZkLoginStorage(service: "com.opendive.suikit.zklogin.tests")
    }

    // Clean up keychain after each test
    override func tearDown() {
        // Clean up keys for test users
        try? storage.clearUserData(forUser: "test-user-1")
        try? storage.clearUserData(forUser: "test-user-2")
        try? storage.clearUserData(forUser: "google-user-123")
        try? storage.clearUserData(forUser: "google-user-456")
        super.tearDown()
    }

    // Test storing and retrieving an ephemeral private key
    func testStoreAndRetrieveEphemeralKey() throws {
        // Generate a test key (just use some random bytes for testing)
        let privateKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let userId = "test-user-1"

        // Store the key
        try storage.storeEphemeralKey(privateKey, forUser: userId)

        // Retrieve the key
        let retrievedKey = try storage.retrieveEphemeralKey(forUser: userId)

        // Verify the key matches
        XCTAssertEqual(retrievedKey, privateKey)
    }

    // Test storing and retrieving a user salt
    func testStoreAndRetrieveUserSalt() throws {
        // Generate a test salt
        let salt = "test-salt-value"
        let userId = "google-user-123"

        // Store the salt
        try storage.storeSalt(salt, forUser: userId)

        // Retrieve the salt
        let retrievedSalt = try storage.retrieveSalt(forUser: userId)

        // Verify the salt matches
        XCTAssertEqual(retrievedSalt, salt)
    }

    // Test clearing user data
    func testClearUserData() throws {
        // Set up test data
        let privateKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let salt = "test-salt-value"
        let userId = "test-user-2"

        // Store key and salt
        try storage.storeEphemeralKey(privateKey, forUser: userId)
        try storage.storeSalt(salt, forUser: userId)

        // Verify data exists
        XCTAssertEqual(try storage.retrieveEphemeralKey(forUser: userId), privateKey)
        XCTAssertEqual(try storage.retrieveSalt(forUser: userId), salt)

        // Clear user data
        try storage.clearUserData(forUser: userId)

        // Verify data is gone
        XCTAssertThrowsError(try storage.retrieveEphemeralKey(forUser: userId), "Should throw after data is cleared")
        XCTAssertThrowsError(try storage.retrieveSalt(forUser: userId), "Should throw after data is cleared")
    }

    // Test overwriting existing key
    func testOverwriteExistingKey() throws {
        // Generate two different keys
        let privateKey1 = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let privateKey2 = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let userId = "test-user-1"

        // Store the first key
        try storage.storeEphemeralKey(privateKey1, forUser: userId)

        // Verify it was stored
        XCTAssertEqual(try storage.retrieveEphemeralKey(forUser: userId), privateKey1)

        // Store the second key (should overwrite)
        try storage.storeEphemeralKey(privateKey2, forUser: userId)

        // Verify the second key is retrieved
        let retrievedKey = try storage.retrieveEphemeralKey(forUser: userId)
        XCTAssertEqual(retrievedKey, privateKey2)
        XCTAssertNotEqual(retrievedKey, privateKey1)
    }

    // Test overwriting existing salt
    func testOverwriteExistingSalt() throws {
        // Generate two different salts
        let salt1 = "salt-value-1"
        let salt2 = "salt-value-2"
        let userId = "test-user-1"

        // Store the first salt
        try storage.storeSalt(salt1, forUser: userId)

        // Verify it was stored
        XCTAssertEqual(try storage.retrieveSalt(forUser: userId), salt1)

        // Store the second salt (should overwrite)
        try storage.storeSalt(salt2, forUser: userId)

        // Verify the second salt is retrieved
        let retrievedSalt = try storage.retrieveSalt(forUser: userId)
        XCTAssertEqual(retrievedSalt, salt2)
        XCTAssertNotEqual(retrievedSalt, salt1)
    }
}
