//
//  ZkLoginAuthenticator.swift
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

/// A comprehensive zkLogin signer that can sign transactions and personal messages
public class ZkLoginSigner {
    /// The Sui provider for network operations
    private let provider: SuiProvider

    /// The ephemeral keypair used for signing
    private let ephemeralKeyPair: Account

    /// The zkLogin signature structure (contains proof, metadata, but not user signature until signing)
    private var zkLoginSignatureTemplate: zkLoginSignature

    /// The user's zkLogin address
    private let userAddress: String

    /// Optional GraphQL client for signature verification
    private let graphQLClient: GraphQLClientProtocol?

    /// Initialize a new ZkLoginAuthenticator
    /// - Parameters:
    ///   - provider: The Sui provider for network operations
    ///   - ephemeralKeyPair: The ephemeral keypair used for signing
    ///   - zkLoginSignature: The zkLogin signature structure template
    ///   - userAddress: The user's zkLogin address
    ///   - graphQLClient: Optional GraphQL client for signature verification
    public init(
        provider: SuiProvider,
        ephemeralKeyPair: Account,
        zkLoginSignature: zkLoginSignature,
        userAddress: String,
        graphQLClient: GraphQLClientProtocol? = nil
    ) {
        self.provider = provider
        self.ephemeralKeyPair = ephemeralKeyPair
        self.zkLoginSignatureTemplate = zkLoginSignature
        self.userAddress = userAddress
        self.graphQLClient = graphQLClient
    }

    /// Get the zkLogin address for this signer
    /// - Returns: The Sui address string
    public func getAddress() -> String {
        return userAddress
    }

    /// Create a zkLogin public identifier for verification purposes
    /// - Returns: A zkLoginPublicIdentifier for signature verification
    public func getPublicKey() throws -> zkLoginPublicIdentifier {
        // Extract issuer from the signature template
        let issClaimJWT = zkLoginSignatureInputsClaim(
            value: zkLoginSignatureTemplate.inputs.issBase64Details.value,
            indexMod4: zkLoginSignatureTemplate.inputs.issBase64Details.indexMod4
        )
        let iss = try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss") as String

        return try zkLoginPublicIdentifier(
            addressSeed: BigInt(zkLoginSignatureTemplate.inputs.addressSeed)!,
            iss: iss,
            client: graphQLClient
        )
    }

    /// Sign raw bytes with the ephemeral keypair and create a complete zkLogin signature
    /// - Parameter bytes: The bytes to sign
    /// - Returns: A complete zkLogin signature
    private func signBytes(_ bytes: [UInt8]) throws -> zkLoginSignature {
        // Sign with the ephemeral keypair
        let ephemeralSignature = try ephemeralKeyPair.sign(Data(bytes))

        // Create a complete zkLogin signature with the user signature
        var completeSignature = zkLoginSignatureTemplate
        completeSignature.userSignature = ephemeralSignature.signature.bytes

        return completeSignature
    }

    /// Sign a transaction block and return the serialized signature
    /// - Parameter transactionData: The transaction data bytes to sign
    /// - Returns: A serialized zkLogin signature string
    public func signTransaction(_ transactionData: [UInt8]) throws -> String {
        let signature = try signBytes(transactionData)
        return try signature.getSignature()
    }

    /// Sign a personal message and return the serialized signature
    /// - Parameter message: The message bytes to sign
    /// - Returns: A serialized zkLogin signature string
    public func signPersonalMessage(_ message: [UInt8]) throws -> String {
        // For personal messages, we need to add the personal message prefix
        let messageWithPrefix = RawSigner.messageWithIntent(.PersonalMessage, Data(message))
        let signature = try signBytes([UInt8](messageWithPrefix))
        return try signature.getSignature()
    }

    /// Sign and execute a transaction using zkLogin authentication
    /// - Parameters:
    ///   - transactionBlock: The transaction to execute
    ///   - options: Optional execution parameters
    /// - Returns: The transaction execution response
    public func signAndExecuteTransaction(
        transactionBlock: inout TransactionBlock,
        options: SuiTransactionBlockResponseOptions = .init()
    ) async throws -> SuiTransactionBlockResponse {
        // Ensure the transaction has the zkLogin user address as sender
        try transactionBlock.setSender(sender: userAddress)

        // Build the transaction
        let bytes = try await transactionBlock.build(self.provider)

        // Sign the transaction data with our zkLogin signer
        let serializedSignature = try signTransaction(bytes.bytes)

        // Execute the transaction with the zkLogin signature
        var resp = try await provider.executeTransactionBlock(
            transactionBlock: bytes.bytes,
            signature: serializedSignature,
            options: options
        )

        // Wait for confirmation
        resp = try await provider.waitForTransaction(tx: resp.digest)
        return resp
    }

    public func executeTransaction(
        transactionBlock: [UInt8],
        options: SuiTransactionBlockResponseOptions = .init()
    ) async throws -> SuiTransactionBlockResponse {
        // Sign the transaction data with our zkLogin signer
        let serializedSignature = try signTransaction(transactionBlock)

        // Execute the transaction with the zkLogin signature
        var resp = try await provider.executeTransactionBlock(
            transactionBlock: transactionBlock,
            signature: serializedSignature,
            options: options
        )

        // Wait for confirmation
        resp = try await provider.waitForTransaction(tx: resp.digest)
        return resp
    }

    /// Sign and execute a transaction block using zkLogin authentication
    /// - Parameters:
    ///   - transactionBlock: The transaction block to execute
    ///   - options: Optional execution parameters
    /// - Returns: The transaction execution response
    public func signAndExecuteTransactionBlock(
        transactionBlock: inout TransactionBlock,
        options: SuiTransactionBlockResponseOptions = .init()
    ) async throws -> SuiTransactionBlockResponse {
        var txBlock = transactionBlock
        return try await signAndExecuteTransaction(transactionBlock: &txBlock, options: options)
    }

    /// Verify a zkLogin signature against transaction data
    /// - Parameters:
    ///   - transactionData: The transaction data bytes
    ///   - signature: The zkLogin signature to verify
    /// - Returns: True if signature is valid, false otherwise
    public func verifyTransaction(
        transactionData: [UInt8],
        signature: zkLoginSignature
    ) async throws -> Bool {
        guard self.graphQLClient != nil else {
            throw SuiError.customError(message: "GraphQL client required for verification")
        }

        let publicKey = try getPublicKey()
        return try await publicKey.verifyTransaction(
            transactionData: transactionData,
            signature: signature
        )
    }

    /// Verify a zkLogin signature against a personal message
    /// - Parameters:
    ///   - message: The message bytes
    ///   - signature: The zkLogin signature to verify
    /// - Returns: True if signature is valid, false otherwise
    public func verifyPersonalMessage(
        message: [UInt8],
        signature: zkLoginSignature
    ) async throws -> Bool {
        guard self.graphQLClient != nil else {
            throw SuiError.customError(message: "GraphQL client required for verification")
        }

        let publicKey = try getPublicKey()
        return try await publicKey.verifyPersonalMessage(
            message: message,
            signature: signature
        )
    }
}

/// Utility methods for zkLogin signature operations
extension ZkLoginAuthenticator {
    /// Parse a serialized zkLogin signature string
    /// - Parameter serialized: The base64 encoded signature string
    /// - Returns: A parsed zkLogin signature
    public static func parseSignature(_ serialized: String) throws -> zkLoginSignature {
        return try zkLoginSignature.parse(serialized: serialized)
    }

    /// Serialize a zkLogin signature to a string
    /// - Parameter signature: The zkLogin signature
    /// - Returns: A base64 encoded signature string
    public static func serializeSignature(_ signature: zkLoginSignature) throws -> String {
        return try signature.getSignature()
    }

    /// Parse a serialized zkLogin signature and extract the public key
    /// - Parameters:
    ///   - serializedSignature: The serialized signature string
    ///   - graphQLClient: Optional GraphQL client for verification
    /// - Returns: A tuple containing the public key and signature
    public static func parseSerializedZkLoginSignature(
        _ serializedSignature: String,
        graphQLClient: GraphQLClientProtocol? = nil
    ) throws -> (publicKey: zkLoginPublicIdentifier, signature: zkLoginSignature) {
        let signature = try parseSignature(serializedSignature)

        // Extract issuer from signature
        let issClaimJWT = zkLoginSignatureInputsClaim(
            value: signature.inputs.issBase64Details.value,
            indexMod4: signature.inputs.issBase64Details.indexMod4
        )
        let iss = try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss") as String

        let publicKey = try zkLoginPublicIdentifier(
            addressSeed: BigInt(signature.inputs.addressSeed)!,
            iss: iss,
            client: graphQLClient
        )

        return (publicKey: publicKey, signature: signature)
    }
}
