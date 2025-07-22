//
//  ZkProofService.swift
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

/// Protocol defining a service that can generate ZK proofs
public protocol ZkProofService {
    /// Generate a ZK proof for zkLogin
    /// - Parameters:
    ///   - jwt: The JWT token
    ///   - userSalt: The user's salt
    ///   - ephemeralPublicKey: The ephemeral public key bytes
    ///   - maxEpoch: The maximum epoch
    ///   - jwtRandomness: Randomness used in nonce generation
    /// - Returns: ZK proof components
    func generateProof(
        jwt: String,
        userSalt: String,
        ephemeralPublicKey: [UInt8],
        maxEpoch: UInt64,
        jwtRandomness: [UInt8]
    ) async throws -> ZkProof
}

/// A ZK proof for zkLogin
public struct ZkProof {
    public let proofPoints: zkLoginSignatureInputsProofPoints
    public let headerBase64: String
    public let issBase64Details: zkLoginSignatureInputsClaim

    public init(
        proofPoints: zkLoginSignatureInputsProofPoints,
        headerBase64: String,
        issBase64Details: zkLoginSignatureInputsClaim
    ) {
        self.proofPoints = proofPoints
        self.headerBase64 = headerBase64
        self.issBase64Details = issBase64Details
    }
}

/// Default implementation of ZkProofService using a REST API
public class RemoteZkProofService: ZkProofService {
    private let url: URL
    private let session: URLSession

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    public func generateProof(
        jwt: String,
        userSalt: String,
        ephemeralPublicKey: [UInt8],
        maxEpoch: UInt64,
        jwtRandomness: [UInt8]
    ) async throws -> ZkProof {
        // Convert inputs to expected format
        let requestBody: [String: Any] = [
            "jwt": jwt,
            "extendedEphemeralPublicKey": Data(ephemeralPublicKey).base64EncodedString(),
            "maxEpoch": String(maxEpoch),
            "jwtRandomness": Data(jwtRandomness).base64EncodedString(),
            "salt": userSalt,
            "keyClaimName": "sub"
        ]

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Serialize the request body to JSON
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        // Send the request
        let (data, response) = try await session.data(for: request)

        // Check for successful response
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SuiError.customError(message: "Proof service error")
        }

        // Parse the response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SuiError.customError(message: "Invalid proof service response format")
        }

        // Extract proof points
        guard let proofPointsJson = json["proofPoints"] as? [String: Any] else {
            throw SuiError.customError(message: "Missing proof points in response")
        }

        // Extract the three arrays of points
        guard let aPoints = proofPointsJson["a"] as? [String],
              aPoints.count == 3 else {
            throw SuiError.customError(message: "Invalid 'a' points in proof")
        }

        // Extract b-points (array of arrays)
        guard let bPointsArray = proofPointsJson["b"] as? [[String]],
              bPointsArray.count == 3,
              bPointsArray[0].count == 2,
              bPointsArray[1].count == 2,
              bPointsArray[2].count == 2 else {
            throw SuiError.customError(message: "Invalid 'b' points in proof")
        }

        // Extract c-points
        guard let cPoints = proofPointsJson["c"] as? [String],
              cPoints.count == 3 else {
            throw SuiError.customError(message: "Invalid 'c' points in proof")
        }

        let proofPoints = zkLoginSignatureInputsProofPoints(
            a: aPoints,
            b: bPointsArray,
            c: cPoints
        )

        // Extract header Base64
        guard let headerBase64 = json["headerBase64"] as? String else {
            throw SuiError.customError(message: "Missing headerBase64 in proof response")
        }

        // Extract issuerPoints
        guard let issBase64DetailsJson = json["issBase64Details"] as? [String: Any],
              let value = issBase64DetailsJson["value"] as? String,
              let indexMod4 = issBase64DetailsJson["indexMod4"] as? Int else {
            throw SuiError.customError(message: "Invalid issBase64Details in proof response")
        }

        let issBase64Details = zkLoginSignatureInputsClaim(value: value, indexMod4: UInt8(indexMod4))

        return ZkProof(
            proofPoints: proofPoints,
            headerBase64: headerBase64,
            issBase64Details: issBase64Details
        )
    }
}
