//
//  ZkLoginAuthenticatorTests.swift
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

// Note: Any tests that require the use of the GraphQL server must be started on call with the beginning of each test function.
// This is due to the signatures below only being valid for an epoch of 3 or less (e.g., genesis to second block).
final class ZkLoginSignerTests: XCTestCase {
    // Premade signatures for test
    let anEphemeralSignature = "AEp+O5GEAF/5tKNDdWBObNf/1uIrbOJmE+xpnlBD2Vikqhbd0zLrQ2NJyquYXp4KrvWUOl7Hso+OK0eiV97ffwucM8VdtG2hjf/RUGNO5JNUH+D/gHtE9sHe6ZEnxwZL7g=="
    let aSignature = "BQNNMTE3MDE4NjY4MTI3MDQ1MTcyMTM5MTQ2MTI3OTg2NzQ3NDg2NTc3NTU1NjY1ODY1OTc0MzQ4MTA5NDEyNDA0ODMzNDY3NjkzNjkyNjdNMTQxMjA0Mzg5OTgwNjM2OTIyOTczODYyNDk3NTQyMzA5NzI3MTUxNTM4NzY1Mzc1MzAxNjg4ODM5ODE1MTM1ODQ1ODYxNzIxOTU4NDEBMQMCTDE4Njc0NTQ1MDE2MDI1ODM4NDg4NTI3ODc3ODI3NjE5OTY1NjAxNzAxMTgyNDkyOTk1MDcwMTQ5OTkyMzA4ODY4NTI1NTY5OTgyNzNNMTQ0NjY0MTk2OTg2NzkxMTYzMTM0NzUyMTA2NTQ1NjI5NDkxMjgzNDk1OTcxMDE3NjkyNTY5NTkwMTAwMDMxODg4ODYwOTEwODAzMTACTTExMDcyOTU0NTYyOTI0NTg4NDk2MTQ4NjMyNDc0MDc4NDMyNDA2NjMzMjg4OTQ4MjU2NzE4ODA5NzE0ODYxOTg2MTE5MzAzNTI5NzYwTTE5NzkwNTE2MDEwNzg0OTM1MTAwMTUwNjE0OTg5MDk3OTA4MjMzODk5NzE4NjQ1NTM2MTMwNzI3NzczNzEzNDA3NjExMTYxMzY4MDQ2AgExATADTTEwNDIzMjg5MDUxODUzMDMzOTE1MzgwODEwNTE2MTMwMjA1NzQ3MTgyODY3NTk2NDU3MTM5OTk5MTc2NzE0NDc2NDE1MTQ4Mzc2MzUwTTIxNzg1NzE5Njk1ODQ4MDEzOTA4MDYxNDkyOTg5NzY1Nzc3Nzg4MTQyMjU1ODk3OTg2MzAwMjQxNTYxMjgwMTk2NzQ1MTc0OTM0NDU3ATExeUpwYzNNaU9pSm9kSFJ3Y3pvdkwyRmpZMjkxYm5SekxtZHZiMmRzWlM1amIyMGlMQwFmZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkltSTVZV00yTURGa01UTXhabVEwWm1aa05UVTJabVl3TXpKaFlXSXhPRGc0T0RCalpHVXpZamtpTENKMGVYQWlPaUpLVjFRaWZRTTEzMzIyODk3OTMwMTYzMjE4NTMyMjY2NDMwNDA5NTEwMzk0MzE2OTg1Mjc0NzY5MTI1NjY3MjkwNjAwMzIxNTY0MjU5NDY2NTExNzExrgAAAAAAAABhAEp+O5GEAF/5tKNDdWBObNf/1uIrbOJmE+xpnlBD2Vikqhbd0zLrQ2NJyquYXp4KrvWUOl7Hso+OK0eiV97ffwucM8VdtG2hjf/RUGNO5JNUH+D/gHtE9sHe6ZEnxwZL7g=="
    let personalMessageSignature = "BQNMODIxMjAxNjM1OTAxNDk1MDg0Mjg0MTUyNTc3NTE1NjQ4NzI2MjEzOTk0OTQ3ODkwNjkwMTc5ODI5NjEwMTkyNTI3MTY5MTU2NTE4ME0xNjE1NTM3MDU2ODcyNzI3OTgxODg5MzYwMzc1NDQwNzYxNzM3NzcxNTgwOTA2NTUwMTYyODczNjg4MjcyNTU3NTIzMjgzNDkyMzcyNgExAwJNMTE2MTk3MTE1NjYyNDg1NTk1NzUyNzE0MDEzMTI1NzE2OTg5NTkxMDA2MjM3NjM4NzY0NjM1OTEzNDY1NTY2OTM1NzI5NzQxOTE1MDlMNTIyOTU4MjE1NDQ1MzkxMDM4MzYwMzYzNjEzNTY0NDU5MTc1NTk3NDI1OTQyMDg4NjUxMzYwMTQ2Mjc0OTk5Mzg2NTA2MTkyODU2NAJNMTA5MDE5ODc3NzAyNTI5NzkzOTM2NDM4NDU1MjM1MzQ2NTQ4MjY3MTkyODUzMzA2NzQwNTk3Nzg0Nzg3NzYwODQ2Mjc4NjQyNzg0NzJMMjg0MjQxNTQ4Mjg0NjQyNzg5NzAwNjM2OTIyMDk0NDUyNjUzMzgwNzc3ODIxMzQyOTA5NTQ2NDc1ODc0MTE5NTkxMTU5NjE0MzY4MwIBMQEwA00xODg1NDIyNzM3ODk4ODA1MDA3NTM2NTExNjAxNzEzNTYxOTQ1MzA3NDcyOTcwNzE5OTgyOTA5OTA2OTUwMDk3NzgzNTcwNjY1OTU4OEw0ODU5NzY1MTQ5OTgxMDYyMTIxOTc0Njg3NTYxNzc4NDA2ODU0NzAxNjEyNzk4NTU2NTE3NzQ4OTU1NDA5NzgxMjkxNTA1MDYzNjQxATEod2lhWE56SWpvaWFIUjBjSE02THk5dllYVjBhQzV6ZFdrdWFXOGlMQwI+ZXlKcmFXUWlPaUp6ZFdrdGEyVjVMV2xrSWl3aWRIbHdJam9pU2xkVUlpd2lZV3huSWpvaVVsTXlOVFlpZlFNMjA0MzUzNjY2MDAwMzYzNzU3NDU5MjU5NjM0NTY4NjEzMDc5MjUyMDk0NzAyMTkzMzQwMTg1NjQxNTgxNDg1NDQwMzYxOTYyODQ2NDIDAAAAAAAAAGEA+XrHUDMkMaPswTIFsqIgx3yX6j7IvU1T/1yzw4kjKwjgLL0ZtPQZjc2djX7Q9pFoBdObkSZ6JZ4epiOf05q4BrnG7hYw7z5xEUSmSNsGu7IoT3J0z77lP/zuUDzBpJIA"
    let transactionSignature = "BQNNMTUzODUzNzAwODM3MTY5NDUxNzk5NTQ4Nzk3ODgwMjEyODE0MDYxODAzODUyMTA3OTY2NjAyNzYwNjMwMTU4MDE0NzE0MzUwNDU5MDVNMTA3NTk1NzUzNjA4MTczNjIzODQ4NzE1MDY1NTkxMzA0NjEwMTAyNzI4MDg5NDY4OTc2NjUwMDg5NjkzNDUzNDkwNzI1NzkyMjE4NzIBMQMCTDE3NTYyNjk4MTk0Nzg2NzkwNTYzMjk1MjAxNTE2ODQ4OTU4NjIxNTQ2Njc3OTY5MDc4NDYxNzU0OTUzNzE3NjE3MTc4MzU1NjIyODFMNzY5MzM5MjIyNDkwNzAwODEzODgzMTMyNDI0NjYxMjA1NjM1MzkyNTU3Njk3NjY4NjIyMzMyMzMwMzE0MzkyNTg2NTg5NDcxNTMzOAJNMTc3MzUxMTQwOTU4MzY3NzY0NDQ0NTc3MTM2MzAwOTQxNzY2Mzc5NTYwMzc3MzQ0MTQ4MDc4OTcyNDk0NTI5NzI5OTQ0OTA1OTc3NTRMOTMxMzYyMzYyMTUwMzM4OTk0MzU4MjQ1Njc5NDkwMjM5NzUyNjc4NjczNjQ1MTQ4MzY0MTAzNzMyMzkzOTg3MzAxNzE0Nzg2NzA0OQIBMQEwA00yMDg3MDcxNTY2MzU5MTYwOTY5MjAzNzk5MzkyNDkwNzMyMjcwMjUwNTM4NzE5MjEyMjI3OTc5MDg0NzgyMzIxOTI4MjQxODc0OTA3M00yMDUyMjg2NTI1NjMyMjY1NTQzOTY2NTI3ODM3OTI1ODQ5NDcyMDQ0MTYzMzcxNzE3MjM3MTYzOTA5Njk2MTM4ODE0MjM0OTUzNDg4NQExKHdpYVhOeklqb2lhSFIwY0hNNkx5OXZZWFYwYUM1emRXa3VhVzhpTEMCPmV5SnJhV1FpT2lKemRXa3RhMlY1TFdsa0lpd2lkSGx3SWpvaVNsZFVJaXdpWVd4bklqb2lVbE15TlRZaWZRTTIwNDM1MzY2NjAwMDM2Mzc1NzQ1OTI1OTYzNDU2ODYxMzA3OTI1MjA5NDcwMjE5MzM0MDE4NTY0MTU4MTQ4NTQ0MDM2MTk2Mjg0NjQyBQAAAAAAAABhAMY6yGE+HfJrftA5rtd/SH4DxhNNXMCfjZNP5XmIBxi46JE9TQeGoArtwbWF3dSI7Vm1DxkGaXh3TT2tGz0yfwi5xu4WMO8+cRFEpkjbBruyKE9ydM++5T/87lA8waSSAA=="
    let transactionBytes = "AAACACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAxawU0NcBzUEjfOeFhCMcbEO0UZDc8fySmLcBavf7cF8AAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAQEBAAEAAMDw0OKiyouNDkBV7EghDsd9BV2zU0As2gHXCFumHT1cAc/OLfzdVoEphi8yCEaHgSSrh8nwhU6goYIZ39PLEoYkAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADA8NDiosqLjQ5AVexIIQ7HfQVds1NALNoB1whbph09XAEAAAAAAAAAAQAAAAAAAAAA"

    // Create sample zkLogin signature components using realistic test data
    let aSignatureInputs = zkLoginSignatureInputs(
        proofPoints: zkLoginSignatureInputsProofPoints(
            a: [
                "11701866812704517213914612798674748657755566586597434810941240483346769369267",
                "14120438998063692297386249754230972715153876537530168883981513584586172195841",
                "1"
            ],
            b: [
                [
                    "1867454501602583848852787782761996560170118249299507014999230886852556998273",
                    "14466419698679116313475210654562949128349597101769256959010003188886091080310"
                ],
                [
                    "11072954562924588496148632474078432406633288948256718809714861986119303529760",
                    "19790516010784935100150614989097908233899718645536130727773713407611161368046"
                ],
                ["1", "0"]
            ],
            c: [
                "10423289051853033915380810516130205747182867596457139999176714476415148376350",
                "21785719695848013908061492989765777788142255897986300241561280196745174934457",
                "1"
            ]
        ),
        issBase64Details: zkLoginSignatureInputsClaim(value: "yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC", indexMod4: 1),
        headerBase64: "eyJhbGciOiJSUzI1NiIsImtpZCI6ImI5YWM2MDFkMTMxZmQ0ZmZkNTU2ZmYwMzJhYWIxODg4ODBjZGUzYjkiLCJ0eXAiOiJKV1QifQ",
        addressSeed: "13322897930163218532266430409510394316985274769125667290600321564259466511711"
    )

    var toolBox: TestToolbox?
    var graphQLClient: SuiGraphQLClient!

    let graphQLUrl = "http://127.0.0.1:9125"
    let issInput = "https://accounts.google.com"

    override func setUp() async throws {
        self.toolBox = try await TestToolbox()
        // TODO: Implement toggle between localnet and deployed nets
        self.graphQLClient = SuiGraphQLClient(url: URL(string: graphQLUrl)!)
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    // MARK: - Signature Parsing Tests

    func testSignatureParsedSuccessfully() throws {
        // Parse the signature (matching TypeScript test logic)
        let parsedSignature = try ZkLoginAuthenticator.parseSignature(aSignature)

        // Verify the signature components match expected values
        XCTAssertEqual(parsedSignature.maxEpoch, 174)
        XCTAssertEqual(parsedSignature.inputs.addressSeed, "13322897930163218532266430409510394316985274769125667290600321564259466511711")
        XCTAssertEqual(parsedSignature.inputs.headerBase64, "eyJhbGciOiJSUzI1NiIsImtpZCI6ImI5YWM2MDFkMTMxZmQ0ZmZkNTU2ZmYwMzJhYWIxODg4ODBjZGUzYjkiLCJ0eXAiOiJKV1QifQ")

        // Verify user signature matches
        XCTAssertEqual(Data(parsedSignature.userSignature).base64EncodedString(), anEphemeralSignature)

        // Verify proof points
        XCTAssertEqual(parsedSignature.inputs.proofPoints.a[0], "11701866812704517213914612798674748657755566586597434810941240483346769369267")
        XCTAssertEqual(parsedSignature.inputs.proofPoints.a[1], "14120438998063692297386249754230972715153876537530168883981513584586172195841")
        XCTAssertEqual(parsedSignature.inputs.proofPoints.a[2], "1")
    }

    // MARK: - Signature Serialization Tests (matching TypeScript "is serialized successfully")

    func testSignatureSerializedSuccessfully() throws {
        // Create signature from components
        guard let userSignature = Data(base64Encoded: anEphemeralSignature) else {
            XCTFail("Failed to decode ephemeral signature")
            return
        }

        let signature = zkLoginSignature(
            inputs: aSignatureInputs,
            maxEpoch: 174,
            userSignature: [UInt8](userSignature)
        )

        // Serialize and verify it matches expected result
        let serialized = try ZkLoginAuthenticator.serializeSignature(signature)
        XCTAssertEqual(serialized, aSignature)
    }

    // MARK: - Personal Message Verification Tests (matching TypeScript personal message test)

    func testVerifyPersonalMessageWithzkLogin() async throws {
        // Test data: base64 encoding of "hello"
        let messageBytes = "hello".data(using: .utf8)!.bytes

        // Parse the personal message signature
        let parsedSignature = try ZkLoginAuthenticator.parseSignature(personalMessageSignature)

        // Create a zkLogin signer with the mock client
        let toolbox = try fetchToolBox()
        let signer = SuiKit.ZkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: parsedSignature,
            userAddress: "0x1234567890abcdef1234567890abcdef12345678",
            graphQLClient: graphQLClient
        )

        // Verify the message - should succeed
        let result = try await signer.verifyPersonalMessage(
            message: messageBytes,
            signature: parsedSignature
        )
        XCTAssertTrue(result)

        // Test data: base64 encoding of "hello"
        let invalidMessageBytes = "hello1".data(using: .utf8)!.bytes

        let failResult = try await signer.verifyPersonalMessage(
            message: invalidMessageBytes,
            signature: parsedSignature
        )
        XCTAssertFalse(failResult)
    }

    // MARK: - Transaction Verification Tests (matching TypeScript transaction verification test)

    func testVerifyTransactionDataWithzkLogin() async throws {
        // Parse transaction bytes
        guard let txBytes = Data(base64Encoded: transactionBytes) else {
            XCTFail("Failed to decode transaction bytes")
            return
        }

        // Parse the transaction signature
        let parsedSignature = try ZkLoginAuthenticator.parseSignature(transactionSignature)

        // Create a zkLogin signer with the mock client
        let toolbox = try fetchToolBox()
        let signer = SuiKit.ZkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: parsedSignature,
            userAddress: "0x1234567890abcdef1234567890abcdef12345678",
            graphQLClient: graphQLClient
        )

        // Verify the transaction - should succeed
        let result = try await signer.verifyTransaction(
            transactionData: txBytes.bytes,
            signature: parsedSignature
        )
        XCTAssertTrue(result)

        // Test with modified transaction data (should fail)
        var modifiedTxBytes = txBytes.bytes
        if !modifiedTxBytes.isEmpty {
            modifiedTxBytes[0] = modifiedTxBytes[0] ^ 0xFF // Flip bits
        }

        let failResult = try await signer.verifyTransaction(
            transactionData: modifiedTxBytes,
            signature: parsedSignature
        )
        XCTAssertFalse(failResult)
    }

    // MARK: - ZkLoginAuthenticator Creation and Basic Operations Tests

    func testZkLoginAuthenticatorCreation() throws {
        let toolbox = try fetchToolBox()

        let zkSignature = zkLoginSignature(
            inputs: aSignatureInputs,
            maxEpoch: 174,
            userSignature: [UInt8](repeating: 0, count: 64)
        )

        let userAddress = "0x1234567890abcdef1234567890abcdef12345678"

        // Create signer
        let signer = SuiKit.ZkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: zkSignature,
            userAddress: userAddress,
            graphQLClient: graphQLClient
        )

        // Test basic operations
        XCTAssertEqual(signer.getAddress(), userAddress)

        // Test public key creation
        let publicKey = try signer.getPublicKey()
        XCTAssertNotNil(publicKey)
    }

    // MARK: - Signature Creation Tests

    func testzkLoginSignatureCreation() throws {
        let toolbox = try fetchToolBox()

        let signer = SuiKit.ZkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: zkLoginSignature(
                inputs: aSignatureInputs,
                maxEpoch: 174,
                userSignature: []
            ),
            userAddress: "0x1234567890abcdef1234567890abcdef12345678"
        )

        // Test transaction signing
        let txData = "hello world".data(using: .utf8)!.bytes
        let txSignature = try signer.signTransaction(txData)
        XCTAssertFalse(txSignature.isEmpty)
        XCTAssertTrue(txSignature.starts(with: "BQ")) // Should start with zkLogin flag in base64

        // Test personal message signing
        let messageData = "hello world".data(using: .utf8)!.bytes
        let messageSignature = try signer.signPersonalMessage(messageData)
        XCTAssertFalse(messageSignature.isEmpty)
        XCTAssertTrue(messageSignature.starts(with: "BQ")) // Should start with zkLogin flag in base64
    }

    // MARK: - Serialization Utilities Tests

    func testParseSerializedzkLoginSignature() throws {
        // Test the utility function that extracts both public key and signature
        let result = try SuiKit.ZkLoginAuthenticator.parseSerializedZkLoginSignature(
            aSignature,
            graphQLClient: graphQLClient
        )

        // Verify we got both components
        XCTAssertNotNil(result.publicKey)
        XCTAssertNotNil(result.signature)

        // Verify signature components
        XCTAssertEqual(result.signature.maxEpoch, 174)
        XCTAssertEqual(result.signature.inputs.addressSeed, "13322897930163218532266430409510394316985274769125667290600321564259466511711")
    }

    // MARK: - Error Handling Tests

    func testSignerWithoutGraphQLClientThrowsError() async throws {
        let toolbox = try fetchToolBox()

        // Create signer without GraphQL client
        let signer = SuiKit.ZkLoginSigner(
            provider: toolbox.client,
            ephemeralKeyPair: toolbox.account,
            zkLoginSignature: zkLoginSignature(
                inputs: aSignatureInputs,
                maxEpoch: 174,
                userSignature: []
            ),
            userAddress: "0x1234567890abcdef1234567890abcdef12345678"
            // No graphQLClient parameter
        )

        let signature = zkLoginSignature(
            inputs: aSignatureInputs,
            maxEpoch: 174,
            userSignature: []
        )

        // Should throw error when trying to verify without GraphQL client
        do {
            _ = try await signer.verifyTransaction(
                transactionData: [1, 2, 3],
                signature: signature
            )
            XCTFail("Expected error when verifying without GraphQL client")
        } catch {
            XCTAssertTrue(error is SuiError)
        }

        do {
            _ = try await signer.verifyPersonalMessage(
                message: [1, 2, 3],
                signature: signature
            )
            XCTFail("Expected error when verifying without GraphQL client")
        } catch {
            XCTAssertTrue(error is SuiError)
        }
    }
}
