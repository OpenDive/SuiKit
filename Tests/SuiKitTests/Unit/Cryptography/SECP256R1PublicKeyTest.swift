//
//  SECP256R1PublicKeyTest.swift
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
import CryptoKit
import BigInt
@testable import SuiKit

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class SECP256R1PublicKeyTest: XCTestCase {
    struct PublicKeyTestStructure {
        let rawPublicKey: String
        let suiPublicKey: String
        let suiAddress: String
    }

    let testCase = PublicKeyTestStructure(
        rawPublicKey: "A8Ju2r5X3EZ3aYuZzH+Ofs6cd1j2WOwY7lhoJQenulBl",
        suiPublicKey: "AgPCbtq+V9xGd2mLmcx/jn7OnHdY9ljsGO5YaCUHp7pQZQ==",
        suiAddress: "0xafd0f5a4f41c5770c201879518740b83743164ed2445016fbba9ae98e04af8a5"
    )

    let validSecp256r1PublicKey: [UInt8] = [
        2, 39, 50, 43, 58, 137, 26, 10, 40, 13, 107, 193, 251, 44, 187, 35, 210, 143, 84, 144, 111, 214, 64, 127, 95, 116, 31, 109, 239, 87, 98, 96, 154
    ]

    let invalidSecp256r1PublicKey: [UInt8] = Array(repeating: 1, count: 32)

    func testThatInvalidSecp256r1PublicKeysWillThrow() throws {
        func invalidKeyThrow() throws {
            _ = try SECP256R1PublicKey(data: Data(self.invalidSecp256r1PublicKey))
        }

        func invalidBuffer() throws {
            let invalidPubKeyBase64 = Data(self.invalidSecp256r1PublicKey).base64EncodedString()
            _ = try SECP256R1PublicKey(value: invalidPubKeyBase64)
        }

        func invalidEncoding() throws {
            let wrongEncode = Data(self.validSecp256r1PublicKey).hexEncodedString()
            _ = try SECP256R1PublicKey(value: wrongEncode)
        }

        func invalidKeyValue() throws {
            _ = try SECP256R1PublicKey(value: "12345")
        }

        XCTAssertThrowsError(
            try invalidKeyThrow()
        )
        XCTAssertThrowsError(
            try invalidBuffer()
        )
        XCTAssertThrowsError(
            try invalidEncoding()
        )
        XCTAssertThrowsError(
            try invalidKeyValue()
        )
    }

    func testThatSecp256r1PrivateKeyCanInitializeFromBase64Value() throws {
        let pubKeyBase64 = Data(self.validSecp256r1PublicKey).base64EncodedString()
        let publicKey = try SECP256R1PublicKey(value: pubKeyBase64)

        XCTAssertEqual(publicKey.base64(), pubKeyBase64)
        XCTAssertEqual(publicKey.key.compressedRepresentation.count, 33)
        XCTAssertEqual(try SECP256R1PublicKey(data: publicKey.key.compressedRepresentation), publicKey)
    }

    func testThatSuiAddressDerivationWorksAsIntended() throws {
        let key = try SECP256R1PublicKey(value: self.testCase.rawPublicKey)

        XCTAssertEqual(try key.toSuiAddress(), self.testCase.suiAddress)
        XCTAssertEqual(try key.toSuiPublicKey(), self.testCase.suiPublicKey)
    }
}
