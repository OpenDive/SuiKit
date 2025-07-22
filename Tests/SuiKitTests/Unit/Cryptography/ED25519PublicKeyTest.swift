//
//  ED25519PublicKeyTest.swift
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

final class ED25519PublicKeyTest: XCTestCase {
    struct PublicKeyTestStructure {
        let rawPublicKey: String
        let suiPublicKey: String
        let suiAddress: String
    }

    let testCases: [PublicKeyTestStructure] = [
        PublicKeyTestStructure(
            rawPublicKey: "UdGRWooy48vGTs0HBokIis5NK+DUjiWc9ENUlcfCCBE=",
            suiPublicKey: "AFHRkVqKMuPLxk7NBwaJCIrOTSvg1I4lnPRDVJXHwggR",
            suiAddress: "0xd77a6cd55073e98d4029b1b0b8bd8d88f45f343dad2732fc9a7965094e635c55"
        ),
        PublicKeyTestStructure(
            rawPublicKey: "0PTAfQmNiabgbak9U/stWZzKc5nsRqokda2qnV2DTfg=",
            suiPublicKey: "AND0wH0JjYmm4G2pPVP7LVmcynOZ7EaqJHWtqp1dg034",
            suiAddress: "0x7e8fd489c3d3cd9cc7cbcc577dc5d6de831e654edd9997d95c412d013e6eea23"
        ),
        PublicKeyTestStructure(
            rawPublicKey: "6L/l0uhGt//9cf6nLQ0+24Uv2qanX/R6tn7lWUJX1Xk=",
            suiPublicKey: "AOi/5dLoRrf//XH+py0NPtuFL9qmp1/0erZ+5VlCV9V5",
            suiAddress: "0x3a1b4410ebe9c3386a429c349ba7929aafab739c277f97f32622b971972a14a2"
        )
    ]

    let validKeyBase64 = "Uz39UFseB/B38iBwjesIU1JZxY6y+TRL9P84JFw41W4="

    func testThatInvalidLengthPublicKeysThrowAnError() throws {
        func invalidLengthPublicKeyBytes() throws {
            let invalidBytes: [UInt8] = [
                3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]
            _ = try ED25519PublicKey(data: Data(invalidBytes))
        }

        func invalidLengthPublicKeyB64StringLong() throws {
            _ = try ED25519PublicKey(value: "0x300000000000000000000000000000000000000000000000000000000000000000000")
        }

        func invalidLengthPublicKeyB64StringShort() throws {
            _ = try ED25519PublicKey(value: "0x300000000000000000000000000000000000000000000000000000000000000")
        }

        func invalidLengthPublicKeyB64StringIntLong() throws {
            _ = try ED25519PublicKey(value: "135693854574979916511997248057056142015550763280047535983739356259273198796800000")
        }

        func invalidLengthPublicKeyB64StringIntShort() throws {
            _ = try ED25519PublicKey(value: "12345")
        }

        XCTAssertThrowsError(try invalidLengthPublicKeyBytes())
        XCTAssertThrowsError(try invalidLengthPublicKeyB64StringLong())
        XCTAssertThrowsError(try invalidLengthPublicKeyB64StringShort())
        XCTAssertThrowsError(try invalidLengthPublicKeyB64StringIntLong())
        XCTAssertThrowsError(try invalidLengthPublicKeyB64StringIntShort())
    }

    func testThatVerifiesEd25519PublicKeyIsAbleToDecodeB64Strings() throws {
        let key = try ED25519PublicKey(value: self.validKeyBase64)
        XCTAssertEqual(key.base64(), self.validKeyBase64)
    }

    func testThatTheRawBytesAndBufferAreCorrect() throws {
        let key = try ED25519PublicKey(value: self.validKeyBase64)
        XCTAssertEqual(key.key.count, 32)
        XCTAssertEqual(try ED25519PublicKey(data: key.key), key)
    }

    func testThatSuiPublicKeysAndAddressesCanBeDerivedFromPublicKey() throws {
        for testCase in self.testCases {
            let keySuiAddress = try ED25519PublicKey(value: testCase.rawPublicKey)
            XCTAssertEqual(try keySuiAddress.toSuiAddress(), testCase.suiAddress)

            let keySuiPublicKey = try ED25519PublicKey(value: testCase.rawPublicKey)
            XCTAssertEqual(try keySuiPublicKey.toSuiPublicKey(), testCase.suiPublicKey)
        }
    }
}
