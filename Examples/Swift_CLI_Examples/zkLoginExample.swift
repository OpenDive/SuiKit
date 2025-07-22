//
//  zkLoginExample.swift
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
import SuiKit

/// A comprehensive example of using the zkLogin flow in SuiKit
/// This example demonstrates the complete zkLogin authentication and transaction flow
class ZkLoginExample {
    // Configuration
    private let proofServiceUrl: URL
    private let saltServiceUrl: URL
    private let networkUrl: URL

    // Services
    private let provider: SuiProvider
    private let zkLoginAuthenticator: ZkLoginAuthenticator
    private let proofService: RemoteZkProofService

    /// Initialize the zkLogin example
    /// - Parameters:
    ///   - network: The network to connect to (defaults to devnet)
    ///   - proofServiceUrl: URL for the zkLogin proof service
    ///   - saltServiceUrl: URL for the salt service
    public init(
        network: Network = .devnet,
        proofServiceUrl: URL? = nil,
        saltServiceUrl: URL? = nil
    ) {
        // Set up network URLs
        switch network {
        case .devnet:
            self.networkUrl = URL(string: "https://fullnode.devnet.sui.io:443")!
            self.proofServiceUrl = proofServiceUrl ?? URL(string: "https://prover-dev.mystenlabs.com/v1")!
            self.saltServiceUrl = saltServiceUrl ?? URL(string: "https://salt.api.mystenlabs.com/get_salt")!
        case .testnet:
            self.networkUrl = URL(string: "https://fullnode.testnet.sui.io:443")!
            self.proofServiceUrl = proofServiceUrl ?? URL(string: "https://prover.testnet.sui.io/v1")!
            self.saltServiceUrl = saltServiceUrl ?? URL(string: "https://salt.api.mystenlabs.com/get_salt")!
        case .mainnet:
            self.networkUrl = URL(string: "https://fullnode.mainnet.sui.io:443")!
            self.proofServiceUrl = proofServiceUrl ?? URL(string: "https://prover.mainnet.sui.io/v1")!
            self.saltServiceUrl = saltServiceUrl ?? URL(string: "https://salt.api.mystenlabs.com/get_salt")!
        }

        // Initialize services
        self.provider = SuiProvider(url: networkUrl)
        self.zkLoginAuthenticator = ZkLoginAuthenticator(provider: provider)
        self.proofService = RemoteZkProofService(url: proofServiceUrl!)
    }

    /// Step 1: Generate the OAuth URL with nonce
    /// - Parameters:
    ///   - clientId: OAuth client ID
    ///   - redirectUrl: Redirect URL for OAuth flow
    ///   - provider: OAuth provider (Google, Facebook, etc.)
    /// - Returns: A tuple containing the URL, ephemeral keypair, randomness, and max epoch
    public func generateOAuthUrl(
        clientId: String,
        redirectUrl: String,
        provider: OAuthProvider
    ) async throws -> (url: URL, ephemeralKeypair: KeyPair, randomness: [UInt8], maxEpoch: UInt64) {
        // Generate ephemeral keypair - using Secure Enclave compatible key when possible
        let ephemeralKeypair = try ZkLoginAuthenticator.generateEphemeralKeypair(scheme: .secp256r1)

        // Get current epoch and calculate max epoch (current + 2)
        let epochInfo = try await provider.getzkLoginEpochInfo()
        let maxEpoch = epochInfo.epoch + 2

        // Generate randomness for nonce
        let randomness = try ZkLoginAuthenticator.generateRandomness()

        // Generate nonce using ephemeral public key
        let nonce = try ZkLoginAuthenticator.generateNonce(
            publicKey: ephemeralKeypair.publicKey,
            maxEpoch: maxEpoch,
            randomness: randomness
        )

        // Construct OAuth URL based on provider
        let urlString: String
        switch provider {
        case .google:
            urlString = "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(clientId)&response_type=id_token&redirect_uri=\(redirectUrl)&scope=openid&nonce=\(nonce)"
        case .facebook:
            urlString = "https://www.facebook.com/v17.0/dialog/oauth?client_id=\(clientId)&redirect_uri=\(redirectUrl)&scope=openid&nonce=\(nonce)&response_type=id_token"
        case .twitch:
            urlString = "https://id.twitch.tv/oauth2/authorize?client_id=\(clientId)&force_verify=true&lang=en&login_type=login&redirect_uri=\(redirectUrl)&response_type=id_token&scope=openid&nonce=\(nonce)"
        case .apple:
            urlString = "https://appleid.apple.com/auth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUrl)&scope=email&response_mode=form_post&response_type=code%20id_token&nonce=\(nonce)"
        }

        guard let url = URL(string: urlString) else {
            throw SuiError.error(code: .invalidURL)
        }

        return (url, ephemeralKeypair, randomness, maxEpoch)
    }

    /// Step 2: Process the JWT from OAuth and get the user's salt
    /// - Parameter jwt: The JWT token from the OAuth redirect
    /// - Returns: The user salt for zkLogin
    public func getUserSalt(jwt: String) async throws -> String {
        // Parse JWT to extract claims
        let jwtClaims = try JWTUtilities.extractClaims(from: jwt)

        // Create a unique user identifier for storing the salt
        guard let sub = jwtClaims.sub, let iss = jwtClaims.iss else {
            throw SuiError.error(code: .missingJWTClaim)
        }

        // Check if we already have a stored salt for this user
        let userIdentifier = SecurezkLoginStorage.generateUserIdentifier(sub: sub, iss: iss)
        if let storedSalt = try SecurezkLoginStorage.retrieveUserSalt(userIdentifier: userIdentifier) {
            return storedSalt
        }

        // Request salt from salt service
        let requestBody: [String: Any] = [
            "token": jwt
        ]

        var request = URLRequest(url: saltServiceUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Send request and parse response
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SuiError.error(code: .saltServiceError)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let salt = json["salt"] as? String else {
            throw SuiError.error(code: .invalidSaltServiceResponse)
        }

        // Store the salt for future use
        try SecurezkLoginStorage.storeUserSalt(salt, userIdentifier: userIdentifier)

        return salt
    }

    /// Step 3: Process the JWT and salt to create a zkLogin signature and address
    /// - Parameters:
    ///   - jwt: The JWT token from OAuth
    ///   - salt: The user salt
    ///   - ephemeralKeypair: The ephemeral keypair generated earlier
    ///   - maxEpoch: The maximum epoch until which the signature is valid
    ///   - randomness: The randomness used in nonce generation
    /// - Returns: A tuple containing the user's zkLogin address and signature
    public func processAuthentication(
        jwt: String,
        salt: String,
        ephemeralKeypair: KeyPair,
        maxEpoch: UInt64,
        randomness: [UInt8]
    ) async throws -> (address: String, signature: zkLoginSignature) {
        // Get zkLogin address
        let address = try ZkLoginAuthenticator.derivezkLoginAddress(jwt: jwt, userSalt: salt)

        // Generate ZK proof and get zkLogin signature
        let signature = try await ZkLoginAuthenticator.processJWT(
            jwt: jwt,
            userSalt: salt,
            ephemeralKeyPair: ephemeralKeypair,
            maxEpoch: maxEpoch,
            randomness: randomness,
            proofService: proofService
        )

        return (address, signature)
    }

    /// Step 4: Create and submit a transaction with zkLogin
    /// - Parameters:
    ///   - userAddress: The user's zkLogin address
    ///   - ephemeralKeypair: The ephemeral keypair
    ///   - zkLoginSignature: The zkLogin signature
    ///   - recipientAddress: Address to send coins to
    ///   - amount: Amount to send (in MIST)
    /// - Returns: Transaction digest
    public func sendTransaction(
        userAddress: String,
        ephemeralKeypair: KeyPair,
        zkLoginSignature: zkLoginSignature,
        recipientAddress: String,
        amount: UInt64
    ) async throws -> String {
        // Create zkLogin signer
        let zkLoginAuthenticator = ZkLoginAuthenticator.createSigner(
            ephemeralKeyPair: ephemeralKeypair,
            zkLoginSignature: zkLoginSignature,
            userAddress: userAddress
        )

        // Create transaction
        var transaction = try TransactionBlock()

        // Add transaction operations - send coins to recipient
        let coin = try transaction.splitCoins(transaction.gas, [transaction.pure(value: .number(amount))])
        try transaction.transferObjects([coin], transaction.pure(value: .address(recipientAddress)))

        // Sign and execute the transaction
        let response = try await zkLoginAuthenticator.signAndExecuteTransaction(
            transactionBlock: &transaction
        )

        return response.digest
    }

    /// Full example of zkLogin flow (for demonstration purposes)
    /// Note: This method is for illustrating the full flow and would typically
    /// be split across multiple user interactions in a real application
    public func demonstratezkLoginFlow() async throws {
        // Step 1: Generate OAuth URL and ephemeral keypair
        // (Normally this would be the first step, and then the user would complete the OAuth flow in a web view)
        let (url, ephemeralKeypair, randomness, maxEpoch) = try await generateOAuthUrl(
            clientId: "YOUR_CLIENT_ID",
            redirectUrl: "YOUR_REDIRECT_URL",
            provider: .google
        )

        print("Step 1: Generated OAuth URL - \(url)")
        print("Open this URL in a browser and complete the OAuth flow")

        // Step 2: After the OAuth flow, the application would extract the JWT from the redirect URL
        // For this example, we're assuming the JWT is provided
        let jwtToken = "SAMPLE_JWT_TOKEN" // In a real app, this would come from the OAuth redirect

        // Step 3: Get user salt
        let salt = try await getUserSalt(jwt: jwtToken)

        print("Step 2: Retrieved user salt - \(salt)")

        // Step 4: Process authentication to get zkLogin address and signature
        let (userAddress, zkLoginSignature) = try await processAuthentication(
            jwt: jwtToken,
            salt: salt,
            ephemeralKeypair: ephemeralKeypair,
            maxEpoch: maxEpoch,
            randomness: randomness
        )

        print("Step 3: Processed authentication")
        print("User zkLogin address: \(userAddress)")

        // Step 5: Send a transaction
        let recipientAddress = "0xSOME_RECIPIENT_ADDRESS"
        let transactionDigest = try await sendTransaction(
            userAddress: userAddress,
            ephemeralKeypair: ephemeralKeypair,
            zkLoginSignature: zkLoginSignature,
            recipientAddress: recipientAddress,
            amount: 100_000_000 // 0.1 SUI
        )

        print("Step 4: Sent transaction")
        print("Transaction digest: \(transactionDigest)")
    }

    /// OAuth provider types
    public enum OAuthProvider {
        case google
        case facebook
        case twitch
        case apple
    }

    /// Network types
    public enum Network {
        case devnet
        case testnet
        case mainnet
    }
}
