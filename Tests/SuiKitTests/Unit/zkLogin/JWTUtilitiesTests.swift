//
//  JWTUtilitiesTests.swift
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

final class JWTUtilitiesTests: XCTestCase {

    // Test extracting claims from JWT
    func testExtractClaimsFromJWT() throws {
        // Sample JWT with known claims (this is a test JWT, not valid for actual authentication)
        let jwt = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huZG9lQGV4YW1wbGUuY29tIiwiaWF0IjoxNTE2MjM5MDIyLCJhdWQiOiJteS10ZXN0LWF1ZGllbmNlIn0.signature-part-not-needed-for-test"

        // Extract claims
        let claims = try JWTUtilities.extractClaims(from: jwt)

        // Verify extracted claims match expected values
        XCTAssertEqual(claims.iss, "https://accounts.google.com")
        XCTAssertEqual(claims.sub, "1234567890")
        XCTAssertEqual(claims.aud as? String, "my-test-audience")
    }

    // Test error handling for invalid JWT format
    func testInvalidJWTFormat() {
        // Invalid JWT format (missing parts)
        let invalidJWT = "not-a-valid-jwt"

        // Should throw an error when parsing
        XCTAssertThrowsError(try JWTUtilities.extractClaims(from: invalidJWT))
    }

    // Test extracting claims via alternative method
    func testExtractClaimValueMethod() throws {
        // Sample JWT with known claims
        let jwt = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huZG9lQGV4YW1wbGUuY29tIiwiaWF0IjoxNTE2MjM5MDIyLCJhdWQiOiJteS10ZXN0LWF1ZGllbmNlIn0.signature-part-not-needed-for-test"

        // Extract claims using the alternative method
        let claims = try JWTUtilities.extractClaimValue(from: jwt)

        // Verify claims
        XCTAssertEqual(claims.iss, "https://accounts.google.com")
        XCTAssertEqual(claims.sub, "1234567890")
        XCTAssertEqual(claims.aud as? String, "my-test-audience")
    }

    // Test binary conversion utilities
    func testBase64UrlCharTo6Bits() throws {
        // Test a few characters from the base64url character set
        let capitalAChar = try JWTUtilities.base64UrlCharTo6Bits(base64UrlChar: "A") // 'A' is 000000 in base64url
        XCTAssertEqual(capitalAChar, [0, 0, 0, 0, 0, 0])

        let capitalZChar = try JWTUtilities.base64UrlCharTo6Bits(base64UrlChar: "Z") // 'Z' should be 011001 in base64url
        XCTAssertEqual(capitalZChar, [0, 1, 1, 0, 0, 1])

        let lowercaseAChar = try JWTUtilities.base64UrlCharTo6Bits(base64UrlChar: "a") // 'a' is 011010 in base64url
        XCTAssertEqual(lowercaseAChar, [0, 1, 1, 0, 1, 0])

        let lowercaseZChar = try JWTUtilities.base64UrlCharTo6Bits(base64UrlChar: "z") // 'z' should be 110011 in base64url
        XCTAssertEqual(lowercaseZChar, [1, 1, 0, 0, 1, 1])

        // Test with invalid input
        XCTAssertThrowsError(try JWTUtilities.base64UrlCharTo6Bits(base64UrlChar: "AB")) // More than one character
        XCTAssertThrowsError(try JWTUtilities.base64UrlCharTo6Bits(base64UrlChar: "*")) // Not in base64url charset
    }

    // Test base64url string to bit vector conversion
    func testBase64UrlStringToBitVector() throws {
        // Convert "AA" to bit vector (should be 12 bits of zeros)
        let bits = try JWTUtilities.base64UrlStringToBitVector(base64UrlString: "AA")
        XCTAssertEqual(bits, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

        // Test with empty string (should be empty array)
        let emptyBits = try JWTUtilities.base64UrlStringToBitVector(base64UrlString: "")
        XCTAssertEqual(emptyBits, [])
    }

    // Test decoding base64URL strings
    func testDecodeBase64URL() throws {
        // Test case from the Sui zkLogin spec
        let result = try JWTUtilities.decodeBase64URL(s: "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20ifQ", i: 0)
        XCTAssertEqual(result, "{\"iss\":\"https://accounts.google.com\"}")

        // Test error cases
        XCTAssertThrowsError(try JWTUtilities.decodeBase64URL(s: "A", i: 0)) // Too short
        XCTAssertThrowsError(try JWTUtilities.decodeBase64URL(s: "AAAA", i: 3)) // Invalid offset
    }

    // Test verify extended claim
    func testVerifyExtendedClaim() throws {
        // Valid claim
        let validClaim = "\"iss\":\"https://accounts.google.com\","
        let (key, value) = try JWTUtilities.verifyExtendedClaim(claim: validClaim)
        XCTAssertEqual(key, "iss")
        XCTAssertEqual(value as? String, "https://accounts.google.com")

        // Invalid claim (not ending with comma or brace)
        XCTAssertThrowsError(try JWTUtilities.verifyExtendedClaim(claim: "\"iss\":\"test\""))

        // Invalid JSON
        XCTAssertThrowsError(try JWTUtilities.verifyExtendedClaim(claim: "invalid:json,"))
    }

    // Test extract claim value
    func testExtractClaimValue() throws {
        // Create a mock JWT claim
        let mockClaim = zkLoginSignatureInputsClaim(value: "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20ifQ", indexMod4: 0)

        // Extract specific claim value
        let issValue: String = try JWTUtilities.extractClaimValue(claim: mockClaim, claimName: "iss")
        XCTAssertEqual(issValue, "https://accounts.google.com")

        // Test with wrong claim name
        XCTAssertThrowsError(try JWTUtilities.extractClaimValue(claim: mockClaim, claimName: "nonexistent") as String)

        // Test with wrong type
        XCTAssertThrowsError(try JWTUtilities.extractClaimValue(claim: mockClaim, claimName: "iss") as Int)
    }
}
