//
//  File.swift
//
//
//  Created by Marcus Arnett on 6/16/23.
//

import Foundation
import Blake2
import BigInt
import SwiftyJSON

public struct RawSigner: SignerWithProviderProtocol {
    public var provider: SuiProvider
    public var faucetProvider: FaucetClient

    public var account: Account

    public init(account: Account, provider: SuiProvider) {
        self.provider = provider
        self.faucetProvider = FaucetClient(connection: provider.connection)
        
        self.account = account
    }

    public func getAddress() throws -> String {
        return try account.publicKey.toSuiAddress()
    }

    public func signData(data: Data) throws -> String {
        let pubKey = self.account.publicKey.base64()
        let digest = try Blake2.hash(.b2b, size: 32, data: data)
        let signature = try self.account.sign(digest)
        let signatureScheme = self.account.accountType
        return try toSerializedSignature(signature, signatureScheme, pubKey)
    }

    public func requestSuiFromFaucet(_ address: String) async throws -> FaucetCoinInfo {
        try await self.faucetProvider.funcAccount(address)
    }

    public func signMessage(_ input: Data) throws -> SignedMessage {
        let signature = try self.signData(data: messageWithIntent(.PersonalMessage, input))
        return SignedMessage(messageBytes: input.base64EncodedString(), signature: signature)
    }

    public func prepareTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> Data {
        try transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
        return try await transactionBlock.build(self.provider)
    }

    public func signTransactionBlock(transactionBlock: inout TransactionBlock) async throws -> SignedTransaction {
        let txBlockBytes = try await self.prepareTransactionBlock(&transactionBlock)
        let intentMessage = messageWithIntent(.TransactionData, txBlockBytes)
        let signature = try self.signData(data: intentMessage)
        
        return SignedTransaction(
            transactionBlockBytes: txBlockBytes.base64EncodedString(),
            signature: signature
        )
    }

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

    public func getTransactionBlockDigest(_ tx: inout TransactionBlock) async throws -> String {
        try tx.setSenderIfNotSet(sender: try self.getAddress())
        return try await tx.getDigest(self.provider)
    }

    public func getTransactionBlockDigest(_ tx: inout Data) throws -> String {
        return try TransactionBlockDataBuilder.getDigestFromBytes(bytes: tx)
    }

    public func dryRunTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> SuiTransactionBlockResponse {
        try transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
        let dryRunTxBytes = try await transactionBlock.build(self.provider)
        return try await self.provider.dryRunTransactionBlock(transactionBlock: [UInt8](dryRunTxBytes))
    }

    public func dryRunTransactionBlock(_ transactionBlock: String) async throws -> SuiTransactionBlockResponse {
        guard let dryRunTxBytes = Data.fromBase64(transactionBlock) else { throw SuiError.failedData }
        return try await self.provider.dryRunTransactionBlock(transactionBlock: [UInt8](dryRunTxBytes))
    }

    public func dryRunTransactionBlock(_ transactionBlock: Data) async throws -> SuiTransactionBlockResponse {
        return try await self.provider.dryRunTransactionBlock(transactionBlock: [UInt8](transactionBlock))
    }

    // TODO: Implement GetGasCostEstimation
}

public typealias Intent = (IntentScope, IntentVersion, AppId)

public func intentWithScope(_ scope: IntentScope) -> Intent {
    return (scope, .V0, .Sui)
}

public func intentData(_ intent: Intent) -> [UInt8] {
    return [
        UInt8(intent.0.rawValue),
        UInt8(intent.1.rawValue),
        UInt8(intent.2.rawValue)
    ]
}

public func messageWithIntent(_ scope: IntentScope, _ message: Data) -> Data {
    let intent = intentWithScope(scope)
    let intentData = intentData(intent)
    var intentMessage = Data(capacity: intentData.count + message.count)
    intentMessage.append(Data(intentData))
    intentMessage.append(message)
    return intentMessage
}

public func toSerializedSignature(
    _ signature: Signature,
    _ signatureScheme: KeyType,
    _ pubKey: String
) throws -> String {
    guard let pubKeyData = Data(base64Encoded: pubKey) else { throw SuiError.failedData }
    guard let encryptionType = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[signatureScheme.rawValue] else {
        throw SuiError.cannotFindSignatureType
    }
    var serializedSignature = Data(count: signature.signature.count + pubKeyData.count)
    serializedSignature[0] = encryptionType
    serializedSignature[1..<signature.signature.count] = signature.signature
    serializedSignature[1+signature.signature.count..<1+signature.signature.count+pubKeyData.count] = pubKeyData

    return serializedSignature.base64EncodedString()
}
