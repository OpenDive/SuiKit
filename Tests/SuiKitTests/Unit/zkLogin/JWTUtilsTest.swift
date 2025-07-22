//
//  JWTUtilsTest.swift
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

final class JWTUtilsTest: XCTestCase {
    func testThatClaimValuesAreExtractedAsIntended() throws {
        let extractedValue: String = try JWTUtilities.extractClaimValue(
            claim: zkLoginSignatureInputsClaim(
                value: "yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC",
                indexMod4: 1
            ),
            claimName: "iss"
        )
        XCTAssertEqual(extractedValue, "https://accounts.google.com")
    }

    func testThatGeneratingNonceWorksAsIntended() throws {
        let pk = try ED25519PublicKey(value: "dkUcNsSSYV2cFz+L/WAlyxINuXHpah/MJnYZ57/GtKY=")
        let nonce = try zkLoginNonce.generateNonce(
            publicKey: pk,
            maxEpoch: 954,
            randomness: "176720613486626510701195520524108477720"
        )
        XCTAssertEqual("NN9BV-W7MlsscmY042AddYkO1N8", nonce)
    }
}
