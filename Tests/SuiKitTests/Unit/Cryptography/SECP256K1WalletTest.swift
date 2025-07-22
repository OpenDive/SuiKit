//
//  SECP256K1WalletTest.swift
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

final class SECP256K1WalletTest: XCTestCase {
    let privateKeySize = 32

    // Test case from https://github.com/rust-bitcoin/rust-secp256k1/blob/master/examples/sign_verify.rs#L26
    let validSecp256k1SecretKey: [UInt8] = [
        59, 148, 11, 85, 134, 130, 61, 253, 2, 174, 59, 70, 27, 180, 51, 107, 94, 203, 174, 253, 102, 39,
        170, 146, 46, 252, 4, 143, 236, 12, 136, 28
    ]

    // Corresponding to the secret key above.
    let validSecp256k1PublicKey: [UInt8] = [
        2, 29, 21, 35, 7, 198, 183, 43, 14, 208, 65, 139, 14, 112, 205, 128, 231, 245, 41, 91, 141, 134,
        245, 114, 45, 63, 82, 19, 251, 210, 57, 79, 54
    ]

    // Invalid private key with incorrect length
    let invalidSecp256k1SecretKey: [UInt8] = Array(repeating: 1, count: 32 - 1)

    // Invalid public key with incorrect length
    let invalidSecp256k1PublicKey: [UInt8] = Array(repeating: 1, count: 32)

    let testCases = [
        [
            "film crazy soon outside stand loop subway crumble thrive popular green nuclear struggle pistol arm wife phrase warfare march wheat nephew ask sunny firm",
            "AQA9EYZoLXirIahsXHQMDfdi5DPQ72wLA79zke4EY6CP",
            "0x9e8f732575cc5386f8df3c784cd3ed1b53ce538da79926b2ad54dcc1197d2532"
        ],
        [
            "require decline left thought grid priority false tiny gasp angle royal system attack beef setup reward aunt skill wasp tray vital bounce inflict level",
            "Ae+TTptXI6WaJfzplSrphnrbTD5qgftfMX5kTyca7unQ",
            "0x9fd5a804ed6b46d36949ff7434247f0fd594673973ece24aede6b86a7b5dae01"
        ],
        [
            "organ crash swim stick traffic remember army arctic mesh slice swear summer police vast chaos cradle squirrel hood useless evidence pet hub soap lake",
            "AY2iJpGSDMhvGILPjjpyeM1bV4Jky979nUenB5kvQeSj",
            "0x60287d7c38dee783c2ab1077216124011774be6b0764d62bd05f32c88979d5c5"
        ]
    ]

    let testMnemonic = "result crisp session latin must fruit genuine question prevent start coconut brave speak student dismiss"

    func testThatSecp256k1AccountCanBeInitialized() throws {
        let account = try Account(accountType: .secp256k1)
        XCTAssertEqual(account.publicKey.key.getType(), .data)
        XCTAssertEqual((account.publicKey.key as! Data).count, 33)
    }

    func testThatSecp256k1AccountCanBeCreatedUsingASecretKey() throws {
        let secretKey = Data(self.validSecp256k1SecretKey)
        let publicKey = Data(self.validSecp256k1PublicKey)
        let publicKeyB64 = publicKey.base64EncodedString()
        let account = try Account(privateKey: secretKey, accountType: .secp256k1)

        XCTAssertEqual(account.publicKey.key as! Data, publicKey)
        XCTAssertEqual(account.publicKey.base64(), publicKeyB64)
    }

    func testThatCreatingSecp256k1AccountFromInvalidSecretKeyWithThrowAnError() throws {
        func invalidKeyThrow() throws {
            let secretKey = Data(self.invalidSecp256k1SecretKey)
            _ = try Account(privateKey: secretKey, accountType: .secp256k1)
        }

        XCTAssertThrowsError(
            try invalidKeyThrow()
        )
    }

    func testThatSecp256k1AccountCanGenerateUsingRandomSeed() throws {
        let seed = Data(Array(repeating: 8, count: self.privateKeySize))
        let account = try Account(privateKey: seed, accountType: .secp256k1)
        XCTAssertEqual(account.publicKey.base64(), "A/mR+UTR4ZVKf8i5v2Lg148BX0wHdi1QXiDmxFJgo2Yb")
    }

    func testThatSignatureOfSignedSecp256k1DataIsValid() throws {
        let account = try Account(accountType: .secp256k1)
        guard let signedData = "hello world".data(using: .utf8) else {
            XCTFail("Signed Data failed.")
            return
        }

        let signature = try account.sign(signedData)
        XCTAssertTrue(try account.verify(signedData, signature))
    }

    func testThatTheDataIsTheSameAsTheRustImplementation() throws {
        let secretKey = Data(self.validSecp256k1SecretKey)
        let account = try Account(privateKey: secretKey, accountType: .secp256k1)
        guard let signedData = "Hello, world!".data(using: .utf8) else {
            XCTFail("Signed Data failed.")
            return
        }

        let signature = try account.sign(signedData)

        // Assert the signature is the same as the rust implementation. See https://github.com/MystenLabs/fastcrypto/blob/0436d6ef11684c291b75c930035cb24abbaf581e/fastcrypto/src/tests/secp256k1_tests.rs#L115
        XCTAssertEqual(
            try signature.hex(),
            "25d450f191f6d844bf5760c5c7b94bc67acc88be76398129d7f43abdef32dc7f7f1a65b7d65991347650f3dd3fa3b3a7f9892a0608521cbcf811ded433b31f8b"
        )

        XCTAssertTrue(try account.verify(signedData, signature))
    }

    func testThatInvalidMnemonicsForSecp256k1AccountInitializationWillThrow() throws {
        func invalidMnemonics() throws {
            _ = try Account("aaa", accountType: .secp256k1)
        }

        XCTAssertThrowsError(try invalidMnemonics())
    }

    func testThatCreatingSecp256k1AccountFromSecretKeyAndMnemonicsMatchesTheTestCases() throws {
        for testCase in self.testCases {
            let account = try Account(testCase[0], accountType: .secp256k1)
            XCTAssertEqual(try account.publicKey.toSuiAddress(), testCase[2])

            guard let raw = Data.fromBase64(testCase[1]) else {
                XCTFail("Failed to decrypt raw Base64 String")
                return
            }

            if raw[0] != 1 || raw.count != self.privateKeySize + 1 {
                XCTFail("Invalid Key")
                return
            }

            let imported = try Account(privateKey: raw.dropFirst(), accountType: .secp256k1)
            XCTAssertEqual(try imported.publicKey.toSuiAddress(), testCase[2])

            let exported = try imported.export()
            let exportedAccount = try account.export()
            XCTAssertEqual(exported.privateKey, raw.dropFirst().base64EncodedString())
            XCTAssertEqual(exportedAccount.privateKey, raw.dropFirst().base64EncodedString())
        }
    }

    func testThatSigningTransactionBlocksWillWorkForSecp256k1Keys() async throws {
        let account = try Account(accountType: .secp256k1)
        let txBlock = try TransactionBlock()
        let provider = SuiProvider(connection: DevnetConnection())

        try txBlock.setSender(sender: try account.publicKey.toSuiAddress())
        txBlock.setGasPrice(price: 5)
        txBlock.setGasBudget(price: 100)
        let digest: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        try txBlock.setGasPayment(payments: [
            SuiObjectRef(
                objectId: String(
                    format: "%.0f",
                    Double.random(in: 0..<100000)
                ).padding(
                    toLength: 64,
                    withPad: "0",
                    startingAt: 0
                ),
                version: "\(UInt64.random(in: 0..<10000))",
                digest: digest.base58EncodedString
            )
        ])

        let bytes = try await txBlock.build(provider)
        let serializedSignature = try account.signTransactionBlock([UInt8](bytes))

        XCTAssertTrue(try account.verifyTransactionBlock([UInt8](bytes), serializedSignature))
    }

    func testThatSigningPersonalMessagesWillWorkForSecp256k1Keys() throws {
        let account = try Account(accountType: .secp256k1)
        guard let message = "hello world".data(using: .utf8) else {
            XCTFail()
            return
        }

        let serializedSignature = try account.signPersonalMessage([UInt8](message))
        XCTAssertTrue(try account.verifyPersonalMessage([UInt8](message), serializedSignature))
    }
}
