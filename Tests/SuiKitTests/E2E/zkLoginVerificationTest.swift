//
//  zkLoginVerificationTest.swift
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

final class zkLoginVerificationTest: XCTestCase {
    // Test zkLogin signature from the TypeScript tests
    let zkLoginPersonalMessageSignature = "BQNMODI5ODYxODE0NDc0OTMzMTE3MzY3MzcxNjI1NTQxMTgyOTIzOTM2NjE1MDg5Mjk4NzIzNjUxNzgzMzc1MDUxMDA5MzE2MTk5NDQxNE0xMzgyODM4MTg4OTc0NjYxMzY0MTM5OTEzMTIwNTQ5MjgzMzU3NjI2OTEwNTQwNTA4OTUwNDAwMDIzNDYzMDQ3OTQxNzA5OTUyMjUxNwExAwJNMTIxNDg0MDgwNzQzODg1OTAxOTc3MTYyNjQ1ODMyNDE4MjI1ODYzNDI0MTMzNDQyNjg0ODI2NTgxODgyODgzMDQ5NTIwMTAwOTM5NTBMMTA1NzU5NTIwODkxODY1ODM3NjAwNjE0MDU4NjA3MDg5MzI0NDI4NzMwNzEwMjUyMTgyNTIzNzYyNjI3NTUwNzY0MDcyNDI0NzA0MQJMOTMyNjQ2NTQ5OTA1MjgzNDE0Mzc3MDE0MjQxMjc2NzQ3MTQ5NzA1ODgzODcxMzMyOTYzMzc2NzM1MzYyNjc4OTAzOTg5NDUzNjkyNE0xMTAyNjcwNjg3NTMwOTc1Njc5MjAxNDY3MzI1NDk5ODcxNDA5NjcwODkxOTE0MTk3NzcyNTYzNjQxODgwMzg2NTI3OTEyMDM5MjE5MAIBMQEwA00xMjU3MjgxMTA3MTQ5OTg0OTc5MDExMDE3ODk2NDQwNTg2NTc1ODEwMzU5OTEyMzI0OTk3OTA3MjcxNTg5OTU5MjIxNDg3NzMxMzgxTDEwNzYyNzAyMzMwNjQ0Mzg4OTM1NjM2NTEyNTY5NDQyMDYyNDM0ODA5ODQ2MzU4MjAxMDQwNjIxODYxMTkxMDYwODMwMjI5NTM2NgExKHdpYVhOeklqb2lhSFIwY0hNNkx5OXZZWFYwYUM1emRXa3VhVzhpTEMCPmV5SnJhV1FpT2lKemRXa3RhMlY1TFdsa0lpd2lkSGx3SWpvaVNsZFVJaXdpWVd4bklqb2lVbE15TlRZaWZRTTIwNDM1MzY2NjAwMDM2Mzc1NzQ1OTI1OTYzNDU2ODYxMzA3OTI1MjA5NDcwMjE5MzM0MDE4NTY0MTU4MTQ4NTQ0MDM2MTk2Mjg0NjQyAwAAAAAAAAAA+XrHUDMkMaPswTIFsqIgx3yX6j7IvU1T/1yzw4kjKwjgLL0ZtPQZjc2djX7Q9pFoBdObkSZ6JZ4epiOf05q4BrnG7hYw7z5xEUSmSNsGu7IoT3J0z77lP/zuUDzBpJIA"

    let zkLoginTransactionSignature = "BQNNMTU3OTIzODY1NTAzNzA4NzM5OTYzOTkzNDc3MzM0NTE2MDk4OTk0MzMxOTU5MTE3NzAzNjA0NTA4OTA1NDQyMTUzNTk0NDA5ODcwME0xMzE4ODg0MTc0Mjc5ODQwNTE2ODI1MTM2OTY3MDc2MjU2Mzk5NzM3Njg0MTg4OTg3ODI5MjU3OTkwODcyNzc1NDgyNTA3MjYzOTYyOQExAwJNMTg0NzMzMTU5NTUwNDI3MDI2NzM5NjE5MDYxMzg1NjgyODEzMzkzOTcwMzc5MTMzMzYzOTQzNjAxNTMzNDExOTEwNDYzMzc0MDkxMTlMNDA1MjQ5NDA4OTk1NDk1MjQ5NzI4Mjc1MTI5NzQwMzA1NDQ0MTQ5OTE2NDYzMDQwMzA0MTAyNTIyMTEzOTgzMjY1MjU3ODI5MDUyOAJMNDkxNjA3NDg3ODU5NDkzNzk3ODY5ODMyNjI1NzY2NDE3NjMxODA4MzMzNzg0NjM0Mzk0OTA2NDUzNDc5NTM0MzAzMzMxOTE4ODQ1NDRMNzQzMjcyMzkyNTYxMzM4OTE2MzcxNDczOTIxMjkzODU2NDc3ODg5MDE3MDM1ODE0MjM0MzIxOTg4OTc4ODU3Mjg5NDcxMTE0NDE5MQIBMQEwA00xMTQ3OTIyNjUxNDg0MDA3NzUzNjg0MTg4NTIwNDkzMzAyNTg3NzE0NTAwMzYwNjM5NTcyMzYxNjg4NTMxODg2Mjk0MzUwOTExNTE1Nk0xMDc4NTMzMjAxMDgzNjIwODM2NDcwODczOTcxMTA4OTI5Nzc1MTM5MjQ1NDY1NzgxMjM5MzExNDkzMDUzMjM0MDA5MDczMDY4NjAwOQExKHdpYVhOeklqb2lhSFIwY0hNNkx5OXZZWFYwYUM1emRXa3VhVzhpTEMCPmV5SnJhV1FpT2lKemRXa3RhMlY1TFdsa0lpd2lkSGx3SWpvaVNsZFVJaXdpWVd4bklqb2lVbE15TlRZaWZRTTIwNDM1MzY2NjAwMDM2Mzc1NzQ1OTI1OTYzNDU2ODYxMzA3OTI1MjA5NDcwMjE5MzM0MDE4NTY0MTU4MTQ4NTQ0MDM2MTk2Mjg0NjQyBgAAAAAAAAAA+XrHUDMkMaPswTIFsqIgx3yX6j7IvU1T/1yzw4kjKwjgLL0ZtPQZjc2djX7Q9pFoBdObkSZ6JZ4epiOf05q4BrnG7hYw7z5xEUSmSNsGu7IoT3J0z77lP/zuUDzBpJIA"

    // Set up GraphQL client
    var graphQLClient: GraphQLClientProtocol!

    override func setUp() async throws {
        // Set up GraphQL client for tests
        if let graphqlUrl = URL(string: "https://sui-mainnet.mystenlabs.com/graphql") {
            graphQLClient = SuiGraphQLClient(url: graphqlUrl)
        } else {
            XCTFail("Failed to create GraphQL URL")
        }
    }

    // Test verifying personal messages with zkLogin signatures
    func testVerifyPersonalMessageWithzkLogin() async throws {
        // Message to verify - base64 encoded "hello"
        let message = "aGVsbG8="

        // Parse the zkLogin signature
        let signature = try zkLoginSignature.parse(serialized: zkLoginPersonalMessageSignature)

        // Create a zkLogin public identifier from the signature
        let publicKey = try zkLoginPublicIdentifier(
            addressSeed: BigInt(stringLiteral: signature.inputs.addressSeed),
            iss: try extractIssuerFromSignature(signature: signature),
            client: graphQLClient
        )

        // Verify the message
        let verificationResult = try await publicKey.verifyPersonalMessage(
            message: Data(base64Encoded: message)!.bytes,
            signature: signature
        )

        // Should verify successfully
        XCTAssertTrue(verificationResult)

        // Try with an invalid signature (different maxEpoch)
        var invalidSignature = signature
        invalidSignature.maxEpoch = 100 // Change the max epoch to make it invalid

        // Should fail verification
        let invalidResult = try await publicKey.verifyPersonalMessage(
            message: Data(base64Encoded: message)!.bytes,
            signature: invalidSignature
        )

        XCTAssertFalse(invalidResult)
    }

    // Test verifying transaction data with zkLogin signatures
    func testVerifyTransactionDataWithzkLogin() async throws {
        // Transaction data to verify
        let transactionData = "AAACACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAxawU0NcBzUEjfOeFhCMcbEO0UZDc8fySmLcBavf7cF8AAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAQEBAAEAAMDw0OKiyouNDkBV7EghDsd9BV2zU0As2gHXCFumHT1cAc/OLfzdVoEphi8yCEaHgSSrh8nwhU6goYIZ39PLEoYkAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADA8NDiosqLjQ5AVexIIQ7HfQVds1NALNoB1whbph09XAEAAAAAAAAAAQAAAAAAAAAA"

        // Parse transaction data from base64
        guard let txBytes = Data(base64Encoded: transactionData) else {
            XCTFail("Failed to decode transaction data")
            return
        }

        // Parse the zkLogin signature
        let signature = try zkLoginSignature.parse(serialized: zkLoginTransactionSignature)

        // Create a zkLogin public identifier from the signature
        let publicKey = try zkLoginPublicIdentifier(
            addressSeed: BigInt(stringLiteral: signature.inputs.addressSeed),
            iss: try extractIssuerFromSignature(signature: signature),
            client: graphQLClient
        )

        // Verify the transaction
        let verificationResult = try await publicKey.verifyTransaction(
            transactionData: txBytes.bytes,
            signature: signature
        )

        // Should verify successfully
        XCTAssertTrue(verificationResult)

        // Try with a modified transaction data
        var modifiedTxBytes = txBytes.bytes
        if !modifiedTxBytes.isEmpty {
            modifiedTxBytes[0] = modifiedTxBytes[0] ^ 0xFF // Flip bits to change the data
        }

        // Should fail verification
        let invalidResult = try await publicKey.verifyTransaction(
            transactionData: modifiedTxBytes,
            signature: signature
        )

        XCTAssertFalse(invalidResult)
    }

    // Helper to extract issuer from zkLogin signature
    private func extractIssuerFromSignature(signature: zkLoginSignature) throws -> String {
        // Create a JWTClaim from the base64 string
        let issClaimJWT = zkLoginSignatureInputsClaim(value: signature.inputs.issBase64Details.value, indexMod4: signature.inputs.issBase64Details.indexMod4)

        // Extract the issuer value
        return try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss")
    }
}

// Mock GraphQL client for testing
// class MockGraphQLClient: GraphQLClient {
//    override func verifyzkLoginSignature(signature: String, transactionData: [UInt8], currentEpoch: UInt64) async throws -> Bool {
//        // Simple mock implementation that verifies signatures with maxEpoch < 10
//        let parsedSignature = try zkLoginSignature.parse(serialized: signature)
//        return parsedSignature.maxEpoch < 10
//    }
// } 
