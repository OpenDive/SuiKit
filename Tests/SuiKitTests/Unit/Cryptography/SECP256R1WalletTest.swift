//
//  SECP256R1WalletTest.swift
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
final class SECP256R1WalletTest: XCTestCase {
    let validSecp256r1SecretKey: [UInt8] = [
        66, 37, 141, 205, 161, 76, 241, 17, 198, 2, 184, 151, 27, 140, 200, 67, 233, 30, 70, 202, 144, 81, 81, 192, 39, 68, 166, 176, 23, 230, 147, 22
    ]
    let validSecp256r1PublicKey: [UInt8] = [
        2, 39, 50, 43, 58, 137, 26, 10, 40, 13, 107, 193, 251, 44, 187, 35, 210, 143, 84, 144, 111, 214, 64, 127, 95, 116, 31, 109, 239, 87, 98, 96, 154
    ]
    let privateKeySize = 32
    let invalidSecp256r1SecretKey: [UInt8] = Array(repeating: 1, count: 32 - 1)
    let invalidSecp256r1PublicKey: [UInt8] = Array(repeating: 1, count: 32)
    let testCases = [
        [
            "act wing dilemma glory episode region allow mad tourist humble muffin oblige",
             "AiWmZXUcFpUF75H082F2RVJAABS5kcrvb8o09IPH9yUw",
             "0x4a822457f1970468d38dae8e63fb60eefdaa497d74d781f581ea2d137ec36f3a",
             "AgLL1StURWGAemn/8rFn3FsRDVfO/Ssf+bbFaugGBtd70w=="
        ],
        [
            "flag rebel cabbage captain minimum purpose long already valley horn enrich salt",
             "AjaB6aLp4fQabx4NglfGz2Bf01TGKArV80NEOnqDwqNN",
             "0xcd43ecb9dd32249ff5748f5e4d51855b01c9b1b8bbe7f8638bb8ab4cb463b920",
             "AgM2aZKpmTrKs8HuyvOZQ2TCQ0s7ql5Agf4giTcu6FtPHA=="
        ],
        [
            "area renew bar language pudding trial small host remind supreme cabbage era",
             "AtSIEzVpJv+bJH3XptEq63vsuK+te1KRSY7JsiuJfcdK",
             "0x0d9047b7e7b698cc09c955ea97b0c68c2be7fb3aebeb59edcc84b1fb87e0f28e",
             "AgJ0BrsxGK2gI3pl7m6L67IXusKo99w4tMDDZCwXhnUm/Q=="
        ]
    ]
    let testMnemonic = "open genre century trouble allow pioneer love task chat salt drive income"

    func testThatSecp256r1PrivateKeysCanBeInitialized() throws {
        let account = try Account(accountType: .secp256r1)
        XCTAssertEqual((account.publicKey.key as! P256.Signing.PublicKey).compressedRepresentation.count, 33)
    }

    func testThatSecp256r1PrivateKeyCanBeInitializedFromBytes() throws {
        let secretKey = try SECP256R1PrivateKey(key: Data(self.validSecp256r1SecretKey))
        let publicKey = try SECP256R1PublicKey(data: Data(self.validSecp256r1PublicKey))

        let pubKeyBase64 = publicKey.base64()
        let account = Account(
            publicKey: publicKey,
            privateKey: secretKey,
            accountType: .secp256r1
        )

        XCTAssertEqual((account.publicKey.key as! P256.Signing.PublicKey).compressedRepresentation, publicKey.key.compressedRepresentation)
        XCTAssertEqual(account.publicKey.base64(), pubKeyBase64)
    }

    func testThatSecp256r1PrivateKeyThrowsAnErrorWithInvalidBytes() throws {
        func invalidKeyThrow() throws {
            let secretKey = try SECP256R1PrivateKey(key: Data(self.invalidSecp256r1SecretKey))
            let secretKeyBase64 = secretKey.base64()
            guard let secretKeyBase64Output = Data.fromBase64(secretKeyBase64) else { XCTFail("Data is unable to be unencoded"); return; }
            _ = try SECP256R1PrivateKey(key: secretKeyBase64Output)
        }

        XCTAssertThrowsError(
            try invalidKeyThrow()
        )
    }

    func testThatSecp256r1PrivateKeyIsAbleToGenerateFromRandomSeed() throws {
        let seed = Data(Array(repeating: 8, count: self.privateKeySize))
        let account = try Account(privateKey: seed, accountType: .secp256r1)
        XCTAssertEqual(account.publicKey.base64(), "AzrasV1mJWvxXNcWA1s/BBRE5RL+0d1k1Lp1WX0g42bx")
    }

    func testThatSignatureOfDataIsValid() throws {
        let account = try Account(accountType: .secp256r1)
        guard let signData = "hello world".data(using: .utf8) else { XCTFail("Unable to encode message"); return; }
        let signature = try account.sign(signData)

        XCTAssertTrue(try account.verify(signData, signature))
    }

    func testThatSecp256r1WillThrowWithInvalidMnemonics() throws {
        func invalidKeyThrow() throws {
            _ = try SECP256R1PrivateKey("aaa")
        }

        XCTAssertThrowsError(
            try invalidKeyThrow()
        )
    }

    func testThatCreatingSecp256r1KeysFromSecretKeyAndMnemonicWorks() throws {
        for testCase in testCases {
            // Keypair derived from mnemonic
            let account = try Account(testCase[0], accountType: .secp256r1)
            XCTAssertEqual(try account.publicKey.toSuiAddress(), testCase[2])

            // Keypair derived from 32-byte secret key
            guard let raw = Data.fromBase64(testCase[1]) else { XCTFail("Failed to decode message"); return; }
            XCTAssertEqual(raw.count, (self.privateKeySize + 1))
            XCTAssertEqual(try account.export().privateKey, raw.dropFirst().base64EncodedString())

            // The secp256r1 flag is 0x02. See more at [enum SignatureScheme].
            guard raw[0] == 2 && raw.count == (self.privateKeySize + 1) else { XCTFail("Raw data not decoded correctly"); return; }

            let imported = try Account(privateKey: raw.dropFirst(), accountType: .secp256r1)
            XCTAssertEqual(try imported.publicKey.toSuiAddress(), testCase[2])

            // Exported secret key matches the 32-byte secret key.
            let exported = try imported.export()
            XCTAssertEqual(exported.privateKey, raw.dropFirst().base64EncodedString())
        }
    }

    func testThatIncorrectPurposeNodeForSecp256r1PrivateKeyWillThrow() throws {
        func invalidKeyThrow() throws {
            _ = try SECP256R1PrivateKey(self.testMnemonic, "m/54'/784'/0'/0'/0'")
        }

        XCTAssertThrowsError(
            try invalidKeyThrow()
        )
    }

    func testThatIncorrectHardendedNodeForSecp256r1PrivateKeyWillThrow() throws {
        func invalidKeyThrow() throws {
            _ = try SECP256R1PrivateKey(self.testMnemonic, "m/44'/784'/0'/0'/0'")
        }

        XCTAssertThrowsError(
            try invalidKeyThrow()
        )
    }

    func testThatSecp256r1PrivateKeyCanSignATransactionBlock() async throws {
        let account = try Account(accountType: .secp256r1)
        let txb = try TransactionBlock()

        try txb.setSender(sender: try account.publicKey.toSuiAddress())
        txb.setGasPrice(price: BigInt("5"))
        txb.setGasBudget(price: BigInt("100"))
        try txb.setGasPayment(payments: [
            SuiObjectRef(
                objectId: try self.randomAccountAddress(),
                version: self.randomVersion(),
                digest: [UInt8]([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).base58EncodedString
            )
        ])
        let result = try await txb.build(SuiProvider(connection: LocalnetConnection()))

        let serializedSignature = try account.signTransactionBlock([UInt8](result))

        XCTAssertTrue(try account.verifyTransactionBlock([UInt8](result), serializedSignature))
    }

    func testThatSecp256r1PrivateKeyCanSignAPersonalMessage() throws {
        let account = try Account(accountType: .secp256r1)
        guard let signData = "hello world".data(using: .utf8) else { XCTFail("Unable to encode message"); return; }

        let serializedSignature = try account.signPersonalMessage([UInt8](signData))
        XCTAssertTrue(try account.verifyPersonalMessage([UInt8](signData), serializedSignature))
    }

    private func randomAccountAddress() throws -> AccountAddress {
        let numberString = self.randomVersion()
        let paddedString = numberString.padding(toLength: 64, withPad: "0", startingAt: 0)
        return try AccountAddress.fromHex(paddedString)
    }

    private func randomVersion() -> String {
        let randomNumber = Int(arc4random_uniform(100000))
        return String(randomNumber)
    }
}
