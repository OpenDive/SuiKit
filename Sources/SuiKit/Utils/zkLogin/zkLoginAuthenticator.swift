//
//  zkLoginAuthenticator.swift
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
import BigInt

/// Manages the zkLogin authentication flow
public class ZkLoginAuthenticator {
    private let provider: SuiProvider

    public init(provider: SuiProvider) {
        self.provider = provider
    }

    /// Generate an ephemeral keypair for zkLogin
    /// - Parameter scheme: The cryptographic scheme to use (supports Ed25519, Secp256k1, Secp256r1)
    /// - Returns: A new keypair
    public func generateEphemeralKeypair(scheme: SignatureScheme = .ED25519) throws -> Account {
        switch scheme {
        case .ED25519:
            return try Account(accountType: .ed25519)
        case .SECP256K1:
            return try Account(accountType: .secp256k1)
        case .SECP256R1:
            return try Account(accountType: .secp256r1)
        default:
            throw SuiError.error(code: .unsupportedSignatureScheme)
        }
    }

    /// Generate a nonce for the OAuth flow based on the ephemeral public key
    /// - Parameters:
    ///   - publicKey: The ephemeral public key
    ///   - maxEpoch: The maximum epoch until which this nonce is valid
    ///   - randomness: Optional random bytes to include in the nonce
    /// - Returns: A base64 encoded nonce string for use in OAuth
    public func generateNonce(publicKey: any PublicKeyProtocol, maxEpoch: UInt64, randomness: [UInt8]? = nil) throws -> String {
        let jwtRandomness = try randomness ?? generateRandomness()

        // Convert randomness bytes to a BigInt string
        let randomnessData = Data(jwtRandomness)
        let randomnessString = zkLoginNonce.toBigIntBE(bytes: randomnessData).description

        return try zkLoginNonce.generateNonce(
            publicKey: publicKey,
            maxEpoch: Int(maxEpoch),
            randomness: randomnessString
        )
    }

    /// Generate random bytes for use in nonce creation
    /// - Returns: Random bytes
    public func generateRandomness() throws -> [UInt8] {
        // Generate 16 bytes of secure random data
        var randomBytes = [UInt8](repeating: 0, count: 16)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        guard status == errSecSuccess else {
            throw SuiError.error(code: .failedToGenerateRandomData)
        }

        return randomBytes
    }

    /// Get the current epoch from the network
    /// - Returns: The current epoch and related information
    public func getCurrentEpoch() async throws -> EpochInfo {
        let systemState = try await provider.getSuiSystemState()
        return EpochInfo(
            epoch: systemState["epoch"].uInt64Value,
            epochStartTimestampMs: systemState["epochStartTimestampMs"].uInt64Value,
            epochDurationMs: systemState["epochDurationMs"].uInt64Value
        )
    }

    /// Process JWT and salt to derive a zkLogin signature
    /// - Parameters:
    ///   - jwt: The JWT token from OAuth provider
    ///   - userSalt: The user's salt value
    ///   - ephemeralKeyPair: The ephemeral keypair
    ///   - maxEpoch: The maximum epoch for validity
    ///   - randomness: The randomness used in nonce generation
    ///   - proofService: Optional service for ZK proof generation
    /// - Returns: A zkLogin signature object
    public func processJWT(
        jwt: String,
        userSalt: String,
        ephemeralKeyPair: Account,
        maxEpoch: UInt64,
        randomness: [UInt8],
        proofService: ZkProofService? = nil
    ) async throws -> zkLoginSignature {
        // Parse JWT to extract claims
        let jwtClaims = try JWTUtilities.extractClaims(from: jwt)

        // Calculate address seed
        _ = try zkLoginUtilities.generateAddressSeed(
            salt: userSalt,
            keyClaimName: "sub",
            keyClaimValue: jwtClaims.sub ?? "",
            audience: jwtClaims.audienceString() ?? ""
        )

        // Get ZK proof (either from service or directly)
        let proofPoints: zkLoginSignatureInputsProofPoints
        let headerBase64: String
        let issBase64Details: zkLoginSignatureInputsClaim

        if let service = proofService {
            // Get proof from external service
            let proof = try await service.generateProof(
                jwt: jwt,
                userSalt: userSalt,
                ephemeralPublicKey: ephemeralKeyPair.publicKey.toSuiBytes(),
                maxEpoch: maxEpoch,
                jwtRandomness: randomness
            )

            proofPoints = proof.proofPoints
            headerBase64 = proof.headerBase64
            issBase64Details = proof.issBase64Details
        } else {
            throw SuiError.error(code: .missingProofService)
        }

        // Create signature inputs
        let inputs = zkLoginSignatureInputs(
            proofPoints: proofPoints,
            issBase64Details: issBase64Details,
            headerBase64: headerBase64,
            addressSeed: "" // Will be populated from the proofPoints
        )

        // Create the zkLoginSignature (without user signature, that will be added at transaction time)
        return zkLoginSignature(
            inputs: inputs,
            maxEpoch: maxEpoch,
            userSignature: [UInt8]() // Empty signature, will be filled at transaction time
        )
    }

    /// Get the zkLogin address for a user
    /// - Parameters:
    ///   - jwt: The JWT token
    ///   - userSalt: The user's salt
    /// - Returns: The zkLogin Sui address
    public func derivezkLoginAddress(jwt: String, userSalt: String) throws -> String {
        let jwtClaims = try JWTUtilities.extractClaims(from: jwt)

        return try zkLoginPublicKey.deriveAddress(
            keyClaimName: "sub",
            keyClaimValue: jwtClaims.sub ?? "",
            issuer: jwtClaims.iss ?? "",
            audience: jwtClaims.audienceString() ?? "",
            userSalt: userSalt
        )
    }

    /// Create a signer that can sign transactions with zkLogin (legacy version)
    /// - Parameters:
    ///   - ephemeralKeyPair: The ephemeral keypair used for signing
    ///   - zkLoginSignature: The zkLogin signature
    ///   - userAddress: The user's zkLogin address
    /// - Returns: A ZkLoginSigner
    public func createSigner(
        ephemeralKeyPair: Account,
        zkLoginSignature: zkLoginSignature,
        userAddress: String
    ) -> ZkLoginSigner {
        return ZkLoginSigner(
            provider: provider,
            ephemeralKeyPair: ephemeralKeyPair,
            zkLoginSignature: zkLoginSignature,
            userAddress: userAddress
        )
    }

    /// Create a comprehensive zkLogin signer with verification capabilities
    /// - Parameters:
    ///   - ephemeralKeyPair: The ephemeral keypair used for signing
    ///   - zkLoginSignature: The zkLogin signature
    ///   - userAddress: The user's zkLogin address
    ///   - graphQLClient: Optional GraphQL client for signature verification
    /// - Returns: A ZkLoginAuthenticator with enhanced capabilities
    public func createZkLoginSigner(
        ephemeralKeyPair: Account,
        zkLoginSignature: zkLoginSignature,
        userAddress: String,
        graphQLClient: GraphQLClientProtocol? = nil
    ) -> ZkLoginSigner {
        return ZkLoginSigner(
            provider: provider,
            ephemeralKeyPair: ephemeralKeyPair,
            zkLoginSignature: zkLoginSignature,
            userAddress: userAddress,
            graphQLClient: graphQLClient
        )
    }
}

/// Information about the current epoch
public struct EpochInfo {
    public let epoch: UInt64
    public let epochStartTimestampMs: UInt64
    public let epochDurationMs: UInt64
}
