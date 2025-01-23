//
//  KeypairTest.swift
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
import Blake2
@testable import SuiKit

final class KeypairTest: XCTestCase {
    let txBytes = "AAACAQDMdYtdFSLGe6VbgpuIsMksv9Ypzpvkq2jiYq0hAjUpOQIAAAAAAAAAIHGwPza+lUm6RuJV1vn9pA4y0PwVT7k/KMMbUViQS5ydACAMVn/9+BYsttUa90vgGZRDuS6CPUumztJN5cbEY3l9RgEBAQEAAAEBAHUFfdk1Tg9l6STLBoSBJbbUuehTDUlLH7p81kpqCKsaBCiJ034Ac84f1oqgmpz79O8L/UeLNDUpOUMa+LadeX93AgAAAAAAAAAgs1e67e789jSlrzOJUXq0bb7Bn/hji+3F5UoMAbze595xCSZCVjU1ItUC9G7KQjygNiBbzZe8t7YLPjRAQyGTzAIAAAAAAAAAIAujHFcrkJJhZfCmxmCHsBWxj5xkviUqB479oupdgMZu07b+hkrjyvCcX50dO30v3PszXFj7+lCNTUTuE4UI3eoCAAAAAAAAACBIv39dyVELUFTkNv72mat5R1uHFkQdViikc1lTMiSVlOD+eESUq3neyciBatafk9dHuhhrS37RaSflqKwFlwzPAgAAAAAAAAAg8gqL3hCkAho8bb0PoqshJdqQFoRP8ZmQMZDFvsGBqa11BX3ZNU4PZekkywaEgSW21LnoUw1JSx+6fNZKagirGgEAAAAAAAAAKgQAAAAAAAAA"
    let digest = "VMVv+/L/EG7/yhEbCQ1qiSt30JXV8yIm+4xO6yTkqeM="

    // Test cases for Ed25519.
    // First element is the mnemonics, second element is the
    // base64 encoded pubkey, derived using DERIVATION_PATH,
    // third element is the hex encoded address, fourth
    // element is the valid signature produced for TX_BYTES.
    let testCases = [
        [
            "film crazy soon outside stand loop subway crumble thrive popular green nuclear struggle pistol arm wife phrase warfare march wheat nephew ask sunny firm",
            "ImR/7u82MGC9QgWhZxoV8QoSNnZZGLG19jjYLzPPxGk=",
            "0xa2d14fad60c56049ecf75246a481934691214ce413e6a8ae2fe6834c173a6133",
            "NwIObhuKot7QRWJu4wWCC5ttOgEfN7BrrVq1draImpDZqtKEaWjNNRKKfWr1FL4asxkBlQd8IwpxpKSTzcXMAQ=="
        ],
        [
            "require decline left thought grid priority false tiny gasp angle royal system attack beef setup reward aunt skill wasp tray vital bounce inflict level",
            "vG6hEnkYNIpdmWa/WaLivd1FWBkxG+HfhXkyWgs9uP4=",
            "0x1ada6e6f3f3e4055096f606c746690f1108fcc2ca479055cc434a3e1d3f758aa",
            "8BSMw/VdYSXxbpl5pp8b5ylWLntTWfBG3lSvAHZbsV9uD2/YgsZDbhVba4rIPhGTn3YvDNs3FOX5+EIXMup3Bw=="
        ],
        [
            "organ crash swim stick traffic remember army arctic mesh slice swear summer police vast chaos cradle squirrel hood useless evidence pet hub soap lake",
            "arEzeF7Uu90jP4Sd+Or17c+A9kYviJpCEQAbEt0FHbU=",
            "0xe69e896ca10f5a77732769803cc2b5707f0ab9d4407afb5e4b4464b89769af14",
            "/ihBMku1SsqK+yDxNY47N/tAREZ+gWVTvZrUoCHsGGR9CoH6E7SLKDRYY9RnwBw/Bt3wWcdJ0Wc2Q3ioHIlzDA=="
        ]
    ]

    // Test cases for Secp256k1.
    // First element is the mnemonics, second element is the
    // base64 encoded pubkey, derived using DERIVATION_PATH_SECP256K1,
    // third element is the hex encoded address, fourth
    // element is the valid signature produced for TX_BYTES.
    let testCasesSecp256k1 = [
        [
            "film crazy soon outside stand loop subway crumble thrive popular green nuclear struggle pistol arm wife phrase warfare march wheat nephew ask sunny firm",
            "Ar2Vs2ei2HgaCIvcsAVAZ6bKYXhDfRTlF432p8Wn4lsL",
            "0x9e8f732575cc5386f8df3c784cd3ed1b53ce538da79926b2ad54dcc1197d2532",
            "y7a8KDd9Py4i5GIka7zAFSHOCOTVLm9ibDx3wPd6WsQa7C1FUdxz32+h5TYmNNWUpTRgWgdBAeG9OgAnDBg0cQ=="
        ],
        [
            "require decline left thought grid priority false tiny gasp angle royal system attack beef setup reward aunt skill wasp tray vital bounce inflict level",
            "A5IcrmWDxl0J/4MNkrtE1AvwiLZiqih9tjttcGlafw+m",
            "0x9fd5a804ed6b46d36949ff7434247f0fd594673973ece24aede6b86a7b5dae01",
            "ijfLeBFowLQjuUD9h6/q9cmuZGg1Afo0ZgZJsZrJsIt2FSFddIomOzqnan3v1T9aW14aBMAlymUELgryib4Q/A=="
        ],
        [
            "organ crash swim stick traffic remember army arctic mesh slice swear summer police vast chaos cradle squirrel hood useless evidence pet hub soap lake",
            "AuEiECTZwyHhqStzpO/RNBXO89/Wa8oc4BtoneKnl6h8",
            "0x60287d7c38dee783c2ab1077216124011774be6b0764d62bd05f32c88979d5c5",
            "qAZyBPNUOtr2uKNByx9HNpWlDxQrOCjtMajYXGTAtWMnTp1cFYMe6QyT0EsYJ0t5xKtK8xq29yChbpsHWz94qA=="
        ]
    ]

    func testThatEd25519SignDataFunctionsAsIntended() throws {
        guard let txBytesData = Data.fromBase64(txBytes) else {
            XCTFail("Failed to decode transaction.")
            return
        }
        let intentMessage = RawSigner.messageWithIntent(.TransactionData, txBytesData)
        let digest = try Blake2b.hash(size: 32, data: intentMessage)
        XCTAssertEqual(digest.base64EncodedString(), self.digest)

        for testCase in testCases {
            let account = try Account(testCase[0], accountType: .ed25519)
            XCTAssertEqual(account.publicKey.base64(), testCase[1])
            XCTAssertEqual(try account.publicKey.toSuiAddress(), testCase[2])

            let signature = try account.signTransactionBlock([UInt8](txBytesData))
            XCTAssertEqual(signature.signature.base64EncodedString(), testCase[3])

            let isValid = try account.publicKey.verifyTransactionBlock([UInt8](txBytesData), signature)
            XCTAssertTrue(isValid)
        }
    }

    func testThatEd25519AccountCanSignMessages() throws {
        let account = try Account()
        guard let signData = "hello world".data(using: .utf8) else {
            XCTFail("Failed to get data from string.")
            return
        }
        let signature = try account.signPersonalMessage([UInt8](signData))
        let isValid = try account.publicKey.verifyPersonalMessage([UInt8](signData), signature)
        XCTAssertTrue(isValid)
    }

    func testThatEd25519AccountCanThrowFailedVerifiedMessages() throws {
        let account = try Account()
        guard let signData = "hello world".data(using: .utf8) else {
            XCTFail("Failed to get data from string.")
            return
        }
        let signature = try account.signPersonalMessage([UInt8](signData))
        let isValid = try account.publicKey.verifyPersonalMessage([UInt8](signData), signature)
        XCTAssertTrue(isValid)
    }

    func testThatSecp256k1SignDataFunctionsAsIntended() throws {
        guard let txBytesData = Data.fromBase64(txBytes) else {
            XCTFail("Failed to decode transaction.")
            return
        }
        let intentMessage = RawSigner.messageWithIntent(.TransactionData, txBytesData)
        let digest = try Blake2b.hash(size: 32, data: intentMessage)
        XCTAssertEqual(digest.base64EncodedString(), self.digest)

        for testCase in testCasesSecp256k1 {
            let account = try Account(testCase[0], accountType: .secp256k1)
            XCTAssertEqual(account.publicKey.base64(), testCase[1])
            XCTAssertEqual(try account.publicKey.toSuiAddress(), testCase[2])

            let signature = try account.signTransactionBlock([UInt8](txBytesData))
            XCTAssertEqual(signature.signature.base64EncodedString(), testCase[3])

            let isValid = try account.publicKey.verifyTransactionBlock([UInt8](txBytesData), signature)
            XCTAssertTrue(isValid)
        }
    }

    func testThatSecp256k1AccountCanSignMessages() throws {
        let account = try Account(accountType: .secp256k1)
        guard let signData = "hello world".data(using: .utf8) else {
            XCTFail("Failed to get data from string.")
            return
        }
        let signature = try account.signPersonalMessage([UInt8](signData))
        let isValid = try account.publicKey.verifyPersonalMessage([UInt8](signData), signature)
        XCTAssertTrue(isValid)
    }
}
