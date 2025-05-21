//
//  RawSigner.swift
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
import Blake2
import BigInt
import SwiftyJSON

/// `RawSigner` is a struct that conforms to the `SignerWithProviderProtocol`.
/// It provides mechanisms to interact with the Sui blockchain, sign data, and handle transaction blocks.
public struct RawSigner: SignerWithProviderProtocol {
    /// A `SuiProvider` instance, providing various blockchain-related services.
    public var provider: SuiProvider

    /// An instance of `FaucetClient`, used for interacting with a blockchain faucet.
    public var faucetProvider: FaucetClient

    /// Represents a user's blockchain account, containing public and private keys.
    public var account: Account

    public init(account: Account, provider: SuiProvider) {
        self.provider = provider
        self.faucetProvider = FaucetClient(connection: provider.connection)
        self.account = account
    }

    /// Retrieves the address associated with the account.
    /// - Returns: The blockchain address as a `String`.
    /// - Throws: An error if address retrieval fails.
    public func getAddress() throws -> String {
        return try account.publicKey.toSuiAddress()
    }

    /// Signs the provided data with the account's private key.
    /// - Parameter data: The `Data` instance to be signed.
    /// - Returns: The signed data as a base64-encoded `String`.
    /// - Throws: An error if the signing process fails.
    public func signData(data: Data) throws -> String {
        let pubKey = self.account.publicKey.base64()
        let digest = try Blake2b.hash(size: 32, data: data)
        let signature = try self.account.sign(digest)
        let signatureScheme = self.account.accountType
        return try Self.toSerializedSignature(signature, signatureScheme, pubKey)
    }

    /// Requests Sui from a faucet for the given address.
    /// - Parameter address: The blockchain address as a `String`.
    /// - Returns: An instance of `FaucetCoins` containing the details of the acquired coins.
    /// - Throws: An error if the request fails.
    public func requestSuiFromFaucet(_ address: String) async throws -> FaucetCoins {
        try await self.faucetProvider.funcAccount(address)
    }

    /// Signs the provided message with the account's private key.
    /// - Parameter input: The `Data` instance representing the message to be signed.
    /// - Returns: An instance of `SignedMessage` containing the original message and the signature.
    /// - Throws: An error if the signing process fails.
    public func signMessage(_ input: Data) throws -> SignedMessage {
        let signature = try self.signData(data: Self.messageWithIntent(.PersonalMessage, input))
        return SignedMessage(messageBytes: input.base64EncodedString(), signature: signature)
    }

    /// Prepares a transaction block.
    /// - Parameter transactionBlock: The `TransactionBlock` instance to be prepared.
    /// - Returns: A `Data` instance representing the prepared transaction block.
    /// - Throws: An error if the transaction block preparation fails.
    public func prepareTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> Data {
        try transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
        return try await transactionBlock.build(self.provider)
    }

    /// Signs a transaction block.
    /// - Parameter transactionBlock: The `TransactionBlock` instance to be signed.
    /// - Returns: An instance of `SignedTransaction` representing the signed transaction block.
    /// - Throws: An error if the transaction block signing fails.
    public func signTransactionBlock(transactionBlock: inout TransactionBlock) async throws -> SignedTransaction {
        let txBlockBytes = try await self.prepareTransactionBlock(&transactionBlock)
        let intentMessage = Self.messageWithIntent(.TransactionData, txBlockBytes)
        let signature = try self.signData(data: intentMessage)

        return SignedTransaction(
            transactionBlockBytes: txBlockBytes.base64EncodedString(),
            signature: signature
        )
    }

    /// Signs and executes a transaction block.
    /// - Parameters:
    ///   - transactionBlock: The `TransactionBlock` instance to be signed and executed.
    ///   - options: Optional `SuiTransactionBlockResponseOptions` instance.
    ///   - requestType: Optional `SuiRequestType` instance.
    /// - Returns: An instance of `SuiTransactionBlockResponse` representing the response to the transaction block execution.
    /// - Throws: An error if the transaction block execution fails.
    public func signAndExecuteTransactionBlock(
        _ transactionBlock: inout TransactionBlock,
        _ options: SuiTransactionBlockResponseOptions? = nil,
        _ requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        let signedTxBlock = try await self.signTransactionBlock(transactionBlock: &transactionBlock)
        return try await self.provider.executeTransactionBlock(
            transactionBlock: signedTxBlock.transactionBlockBytes,
            signature: signedTxBlock.signature,
            options: options,
            requestType: requestType
        )
    }

    /// Retrieves the digest of a transaction block.
    /// - Parameter tx: The `TransactionBlock` instance whose digest is to be retrieved.
    /// - Returns: The digest of the transaction block as a `String`.
    /// - Throws: An error if retrieving the digest fails.
    public func getTransactionBlockDigest(_ tx: inout TransactionBlock) async throws -> String {
        try tx.setSenderIfNotSet(sender: try self.getAddress())
        return try await tx.getDigest(self.provider)
    }

    /// Dry-runs a transaction block and returns the response.
    /// - Parameter transactionBlock: The `TransactionBlock` instance to be dry-run.
    /// - Returns: An instance of `SuiTransactionBlockResponse` representing the response to the dry-run.
    /// - Throws: An error if the dry-run fails.
    public func getTransactionBlockDigest(_ tx: inout Data) throws -> String {
        return try TransactionBlockDataBuilder.getDigestFromBytes(bytes: tx)
    }

    /// Performs a dry-run of the provided transaction block.
    /// - Parameter transactionBlock: A reference to a `TransactionBlock` instance to be dry-run.
    /// - Returns: A `SuiTransactionBlockResponse` instance representing the response of the dry-run.
    /// - Throws: An error if the dry-run process fails.
    public func dryRunTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> SuiTransactionBlockResponse {
        try transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
        let dryRunTxBytes = try await transactionBlock.build(self.provider)
        return try await self.provider.dryRunTransactionBlock(transactionBlock: [UInt8](dryRunTxBytes))
    }

    /// Performs a dry-run of the provided transaction block.
    /// - Parameter transactionBlock: A `String` representing the base64-encoded transaction block to be dry-run.
    /// - Returns: A `SuiTransactionBlockResponse` instance representing the response of the dry-run.
    /// - Throws: An error if the dry-run process fails or if the input string is not valid base64.
    public func dryRunTransactionBlock(_ transactionBlock: String) async throws -> SuiTransactionBlockResponse {
        guard let dryRunTxBytes = Data.fromBase64(transactionBlock) else { throw SuiError.customError(message: "Failed data") }
        return try await self.provider.dryRunTransactionBlock(transactionBlock: [UInt8](dryRunTxBytes))
    }

    /// Performs a dry-run of the provided transaction block.
    /// - Parameter transactionBlock: A `Data` instance representing the transaction block to be dry-run.
    /// - Returns: A `SuiTransactionBlockResponse` instance representing the response of the dry-run.
    /// - Throws: An error if the dry-run process fails.
    public func dryRunTransactionBlock(_ transactionBlock: Data) async throws -> SuiTransactionBlockResponse {
        return try await self.provider.dryRunTransactionBlock(transactionBlock: [UInt8](transactionBlock))
    }

    // TODO: Implement GetGasCostEstimation

    /// Generates an `Intent` based on the provided `IntentScope`.
    /// - Parameter scope: An `IntentScope` instance defining the scope of the intent.
    /// - Returns: An `Intent` instance representing the generated intent.
    public static func intentWithScope(_ scope: IntentScope) -> Intent {
        return (scope, .V0, .Sui)
    }

    /// Converts the provided `Intent` to an array of `UInt8`.
    /// - Parameter intent: An `Intent` instance to be converted.
    /// - Returns: An array of `UInt8` representing the converted intent.
    public static func intentData(_ intent: Intent) -> [UInt8] {
        return [
            UInt8(intent.0.rawValue),
            UInt8(intent.1.rawValue),
            UInt8(intent.2.rawValue)
        ]
    }

    /// Appends the provided message to the intent data and returns the combined `Data`.
    /// - Parameters:
    ///   - scope: An `IntentScope` instance defining the scope of the intent.
    ///   - message: A `Data` instance representing the message to be appended to the intent data.
    /// - Returns: A `Data` instance representing the combined intent and message.
    public static func messageWithIntent(_ scope: IntentScope, _ message: Data) -> Data {
        let intent = intentWithScope(scope)
        let intentData = intentData(intent)
        var intentMessage = Data(capacity: intentData.count + message.count)
        intentMessage.append(Data(intentData))
        intentMessage.append(message)
        return intentMessage
    }

    /// Serializes the provided signature, signature scheme, and public key.
    /// - Parameters:
    ///   - signature: A `Signature` instance representing the signature to be serialized.
    ///   - signatureScheme: A `KeyType` instance representing the signature scheme to be included in the serialization.
    ///   - pubKey: A `String` representing the base64-encoded public key to be included in the serialization.
    /// - Returns: A base64-encoded `String` representing the serialized signature, signature scheme, and public key.
    /// - Throws: An error if the serialization process fails.
    public static func toSerializedSignature(
        _ signature: Signature,
        _ signatureScheme: KeyType,
        _ pubKey: String
    ) throws -> String {
        guard let pubKeyData = Data(base64Encoded: pubKey) else { throw SuiError.customError(message: "Failed data") }
        guard let encryptionType = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[signatureScheme.rawValue] else {
            throw SuiError.customError(message: "Cannot find signature type for \(signatureScheme.rawValue)")
        }
        var serializedSignature = Data(count: signature.signature.count + pubKeyData.count)
        serializedSignature[0] = encryptionType
        serializedSignature[1..<signature.signature.count] = signature.signature
        serializedSignature[1+signature.signature.count..<1+signature.signature.count+pubKeyData.count] = pubKeyData

        return serializedSignature.base64EncodedString()
    }
}
