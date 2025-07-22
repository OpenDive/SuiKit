//
//  zkLoginAddressTests.swift
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
import BigInt
@testable import SuiKit

final class zkLoginAddressTests: XCTestCase {
    func testThatVerifieszkLoginFunctionsGenerateTheCorrectAddressAsIntended() throws {
        let computedAddress = try zkLoginPublicIdentifier(addressSeed: BigInt("13322897930163218532266430409510394316985274769125667290600321564259466511711"), iss: "https://accounts.google.com")
        try XCTAssertEqual("0xf7badc2b245c7f74d7509a4aa357ecf80a29e7713fb4c44b0e7541ec43885ee1", computedAddress.toSuiAddress())
    }

    func testThatVerifieszkLoginFunctionsGenerateTheCorrectAddressWithLeadingZeros() throws {
        let computedAddress = try zkLoginPublicIdentifier(addressSeed: BigInt("380704556853533152350240698167704405529973457670972223618755249929828551006"), iss: "https://accounts.google.com")
        try XCTAssertEqual("0xbd8b8ed42d90aebc71518385d8a899af14cef8b5a171c380434dd6f5bbfe7bf3", computedAddress.toSuiAddress())
    }

    func testThatAValidJWTTokenShouldConvertOverToAnAddressWithNoErrorsAsIntended() throws {
        let jwt = "eyJraWQiOiJzdWkta2V5LWlkIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI4YzJkN2Q2Ni04N2FmLTQxZmEtYjZmYy02M2U4YmI3MWZhYjQiLCJhdWQiOiJ0ZXN0IiwibmJmIjoxNjk3NDY1NDQ1LCJpc3MiOiJodHRwczovL29hdXRoLnN1aS5pbyIsImV4cCI6MTY5NzU1MTg0NSwibm9uY2UiOiJoVFBwZ0Y3WEFLYlczN3JFVVM2cEVWWnFtb0kifQ."
        let userSalt = "248191903847969014646285995941615069143"
        let address = try zkLoginUtilities.jwtToAddress(jwt: jwt, userSalt: userSalt)
        XCTAssertEqual(address, "0x22cebcf68a9d75d508d50d553dd6bae378ef51177a3a6325b749e57e3ba237d6")
    }

    func testThatVerifiesThatTheSameAddressIsReturnedByBothGoogleISSValuesAsIntended() throws {
        /**
             * {
             * "iss": "https://accounts.google.com",
             * "sub": "1234567890",
             * "aud": "1234567890.apps.googleusercontent.com",
             * "exp": 1697551845,
             * "iat": 1697465445
             * }
         */
        let jwt1 = "eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMjM0NTY3ODkwIiwiYXVkIjoiMTIzNDU2Nzg5MC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImV4cCI6MTY5NzU1MTg0NSwiaWF0IjoxNjk3NDY1NDQ1fQ."

        /**
             * {
             * "iss": "accounts.google.com",
             * "sub": "1234567890",
             * "aud": "1234567890.apps.googleusercontent.com",
             * "exp": 1697551845,
             * "iat": 1697465445
             * }
        */
        let jwt2 = "eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwic3ViIjoiMTIzNDU2Nzg5MCIsImF1ZCI6IjEyMzQ1Njc4OTAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJleHAiOjE2OTc1NTE4NDUsImlhdCI6MTY5NzQ2NTQ0NX0."

        XCTAssertEqual(try zkLoginUtilities.jwtToAddress(jwt: jwt1, userSalt: "0"), try zkLoginUtilities.jwtToAddress(jwt: jwt2, userSalt: "0"))
    }

    func testThatHeadersThatAreTooLongThrowAnError() {
        func tooLongHeader() throws {
            let header = String(repeating: "a", count: (zkLoginUtilities.maxHeaderLengthBase64 + 1))
            let jwt = "\(header)."
            try zkLoginUtilities.lengthChecks(jwt: jwt)
        }
        XCTAssertThrowsError(try tooLongHeader())
    }

    func testThatJWTTokensThatAreTooLongThrowAnError() {
        func tooLongJWT() throws {
            let jwt = ".\(String(repeating: "a", count: zkLoginUtilities.maxPaddedUnsignedJwtLength))"
            try zkLoginUtilities.lengthChecks(jwt: jwt)
        }
        XCTAssertThrowsError(try tooLongJWT())
    }
}
