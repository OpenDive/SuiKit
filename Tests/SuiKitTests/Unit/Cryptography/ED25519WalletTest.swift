//
//  ED25519WalletTest.swift
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

final class ED25519WalletTest: XCTestCase {
    let validSecretKey = "mdqVWeFekT7pqy5T49+tV12jO0m+ESW7ki4zSU9JiCg="
    let privateKeySize = 32

    let testCases = [
        [
            "film crazy soon outside stand loop subway crumble thrive popular green nuclear struggle pistol arm wife phrase warfare march wheat nephew ask sunny firm",
            "AN0JMHpDum3BhrVwnkylH0/HGRHBQ/fO/8+MYOawO8j6",
            "0xa2d14fad60c56049ecf75246a481934691214ce413e6a8ae2fe6834c173a6133"
        ],
        [
            "require decline left thought grid priority false tiny gasp angle royal system attack beef setup reward aunt skill wasp tray vital bounce inflict level",
            "AJrA997C1eVz6wYIp7bO8dpITSRBXpvg1m70/P3gusu2",
            "0x1ada6e6f3f3e4055096f606c746690f1108fcc2ca479055cc434a3e1d3f758aa"
        ],
        [
            "organ crash swim stick traffic remember army arctic mesh slice swear summer police vast chaos cradle squirrel hood useless evidence pet hub soap lake",
            "AAEMSIQeqyz09StSwuOW4MElQcZ+4jHW4/QcWlJEf5Yk",
            "0xe69e896ca10f5a77732769803cc2b5707f0ab9d4407afb5e4b4464b89769af14"
        ]
    ]

    let testMnemonic = "result crisp session latin must fruit genuine question prevent start coconut brave speak student dismiss"

    func testForNewWallet() throws {
        let wallet = try Wallet()
        XCTAssertEqual(wallet.accounts[0].publicKey.key.getType(), .data)
        XCTAssertEqual((wallet.accounts[0].publicKey.key as! Data).count, 32)
    }

    func testForCreatingAccountFromSecretKey() throws {
        guard let secretKey = Data.fromBase64(validSecretKey) else {
            XCTFail("Secret Key '\(validSecretKey)' cannot be converted from Base 64")
            return
        }
        let account = try Account(privateKey: secretKey)
        XCTAssertEqual(account.publicKey.base64(), "Gy9JCW4+Xb0Pz6nAwM2S2as7IVRLNNXdSmXZi4eLmSI=")
    }

    func testThatWalletSecretKeyFromMnemonicsAndAccountSecretKeyMatchesKeytool() throws {
        for testCase in testCases {
            // Keypair derived from mnemonic
            let wallet = try Wallet(mnemonicString: testCase[0])
            XCTAssertEqual(try wallet.accounts[0].publicKey.toSuiAddress(), testCase[2])

            // Keypair derived from 32-byte secret key
            guard let raw = Data.fromBase64(testCase[1]) else {
                XCTFail("Failed to convert \(testCase[1]) from Base 64 to Data")
                return
            }
            if raw[0] != 0 || raw.count != (self.privateKeySize + 1) {
                XCTFail("Invalid Key")
                return
            }
            let secretKey = try ED25519PrivateKey(key: raw.dropFirst())
            let imported = try Account(privateKey: secretKey)
            XCTAssertEqual(try imported.publicKey.toSuiAddress(), testCase[2])

            // Exported secret key matches the 32-byte secret key.
            let exported = try imported.export()
            XCTAssertEqual(exported.privateKey, raw.dropFirst().base64EncodedString())
        }
    }

    func testThatAccountIsCreatedFromRandomSeed() throws {
        let privateKey = try ED25519PrivateKey(key: Data(Array(repeating: 8, count: privateKeySize)))
        let account = try Account(privateKey: privateKey)
        XCTAssertEqual(account.publicKey.base64(), "E5j2LG0aRXxRumpLXz29L2n8qTIWIY3ImX5Ba9F9k8o=")
    }

    func testThatSignatureOfDataIsValid() throws {
        let account = try Account()
        guard let signData = "hello world".data(using: .utf8) else {
            XCTFail("Failed to sign data")
            return
        }
        let signature = try account.sign(signData)
        let isValid = try account.verify(
            signData,
            signature
        )
        XCTAssertTrue(isValid)
    }

    func testThatIncoorectCoinTypeWillThrowForWallet() throws {
        func incorrectCoin() throws {
            _ = try ED25519PrivateKey(testMnemonic, "m/44'/0'/0'/0'/0'")
        }

        XCTAssertThrowsError(
            try incorrectCoin()
        )
    }

    func testThatIncoorectPurposeNodeWillThrowForWallet() throws {
        func incorrectPurposeNode() throws {
            _ = try ED25519PrivateKey(testMnemonic, "m/54'/784'/0'/0'/0'")
        }

        XCTAssertThrowsError(
            try incorrectPurposeNode()
        )
    }

    func testThatSigningTransactionBlockFunctionsAsIntended() async throws {
        let wallet = try Wallet()
        let txBlock = try TransactionBlock()
        let provider = SuiProvider(connection: DevnetConnection())

        try txBlock.setSender(sender: try wallet.accounts[0].publicKey.toSuiAddress())
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
        let serializedSignature = try wallet.accounts[0].signTransactionBlock([UInt8](bytes))

        XCTAssertTrue(try wallet.accounts[0].verifyTransactionBlock([UInt8](bytes), serializedSignature))
    }

    func testThatSigningPersonalMessagesFunctionsAsIntended() throws {
        let wallet = try Wallet()
        guard let message = "hello world".data(using: .utf8) else {
            XCTFail()
            return
        }

        let serializedSignature = try wallet.accounts[0].signPersonalMessage([UInt8](message))
        XCTAssertTrue(try wallet.accounts[0].verifyPersonalMessage([UInt8](message), serializedSignature))
    }
}
