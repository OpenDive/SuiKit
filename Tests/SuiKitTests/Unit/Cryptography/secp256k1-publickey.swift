//
//  secp256k1-publickey.swift
//  
//
//  Created by Marcus Arnett on 8/8/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class SECP256K1PublicKeyTest: XCTestCase {
    struct PublicKeyTestStructure {
        let rawPublicKey: String
        let suiPublicKey: String
        let suiAddress: String
    }

    let validSecp256k1PublicKey: [UInt8] = [
        2, 29, 21, 35, 7, 198, 183, 43, 14, 208, 65, 139, 14, 112, 205, 128, 231, 245, 41, 91, 141, 134,
        245, 114, 45, 63, 82, 19, 251, 210, 57, 79, 54
    ]

    let invalidSecp256k1PublicKey: [UInt8] = Array(repeating: 1, count: 32)
    
    let testCases: [PublicKeyTestStructure] = [
        PublicKeyTestStructure(
            rawPublicKey: "AwTC3jVFRxXc3RJIFgoQcv486QdqwYa8vBp4bgSq0gsI",
            suiPublicKey: "AQMEwt41RUcV3N0SSBYKEHL+POkHasGGvLwaeG4EqtILCA==",
            suiAddress: "0xcdce00b4326fb908fdac83c35bcfbda323bfcc0618b47c66ccafbdced850efaa"
        ),
        PublicKeyTestStructure(
            rawPublicKey: "A1F2CtldIGolO92Pm9yuxWXs5E07aX+6ZEHAnSuKOhii",
            suiPublicKey: "AQNRdgrZXSBqJTvdj5vcrsVl7ORNO2l/umRBwJ0rijoYog==",
            suiAddress: "0xb588e58ed8967b6a6f9dbce76386283d374cf7389fb164189551257e32b023b2"
        ),
        PublicKeyTestStructure(
            rawPublicKey: "Ak5rsa5Od4T6YFN/V3VIhZ/azMMYPkUilKQwc+RiaId+",
            suiPublicKey: "AQJOa7GuTneE+mBTf1d1SIWf2szDGD5FIpSkMHPkYmiHfg==",
            suiAddress: "0x694dd74af1e82b968822a82fb5e315f6d20e8697d5d03c0b15e0178c1a1fcfa0"
        ),
        PublicKeyTestStructure(
            rawPublicKey: "A4XbJ3fLvV/8ONsnLHAW1nORKsoCYsHaXv9FK1beMtvY",
            suiPublicKey: "AQOF2yd3y71f/DjbJyxwFtZzkSrKAmLB2l7/RStW3jLb2A==",
            suiAddress: "0x78acc6ca0003457737d755ade25a6f3a144e5e44ed6f8e6af4982c5cc75e55e7"
        )
    ]

    func testThatInvalidSecp256k1KeysThrowAnError() throws {
        func invalidKey() throws {
            let _ = try SECP256K1PublicKey(data: Data(self.invalidSecp256k1PublicKey))
        }

        func invalidPubkeyBase64() throws {
            let invalidPubkeyBase64 = self.invalidSecp256k1PublicKey.toBase64()
            let _ = try SECP256K1PublicKey(value: invalidPubkeyBase64)
        }

        func invalidKeyHex() throws {
            let invalidPubkeyHex = self.invalidSecp256k1PublicKey.toHexString()
            let _ = try SECP256K1PublicKey(hexString: invalidPubkeyHex)
        }

        func invalidString() throws {
            let _ = try SECP256K1PublicKey(value: "12345")
        }

        XCTAssertThrowsError(try invalidKey())
        XCTAssertThrowsError(try invalidPubkeyBase64())
        XCTAssertThrowsError(try invalidKeyHex())
        XCTAssertThrowsError(try invalidString())
    }
}
