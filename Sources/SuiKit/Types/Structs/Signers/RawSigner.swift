//
//  File.swift
//
//
//  Created by Marcus Arnett on 6/16/23.
//

import Foundation
import Blake2
import BigInt

public struct RawSigner: SignerWithProviderProtocol {
    public var provider: SuiProvider
    public var faucetProvider: FaucetClient
    
    public var wallet: Account
    
    public init(wallet: Account, provider: SuiProvider) {
        self.provider = provider
        self.faucetProvider = FaucetClient(connection: provider.connection)
        
        self.wallet = wallet
    }
    
    public func getAddress() throws -> String {
        return try wallet.address().toSuiAddress()
    }
    
    public func signData(data: Data) throws -> String {
        let pubKey = wallet.address().base64()
        let digest = try Blake2.hash(.b2b, size: 32, data: data)
        let signature = try self.wallet.privateKey.sign(data: digest)
        let signatureScheme = self.wallet.privateKey.type
        return try toSerializedSignature(signature, signatureScheme, pubKey)
    }
    
    public func connect(provider: SuiProvider) throws -> RawSigner {
        return RawSigner(wallet: self.wallet, provider: provider)
    }
    
    public func requestSuiFromFaucet(_ address: String) async throws -> FaucetCoinInfo {
        try await self.faucetProvider.funcAccount(address)
    }
    
    public func signMessage(_ input: Data) throws -> SignedMessage {
        let signature = try self.signData(data: messageWithIntent(.PersonalMessage, input))
        return SignedMessage(messageBytes: input.base64EncodedString(), signature: signature)
    }
    
    public func prepareTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> Data {
        transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
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
    ) async throws -> TransactionBlockResponse {
        let signedTxBlock = try await self.signTransactionBlock(transactionBlock: &transactionBlock)
        return try await self.provider.executeTransactionBlock(
            signedTxBlock.transactionBlockBytes,
            signedTxBlock.signature,
            options,
            requestType
        )
    }
    
    public func getTransactionBlockDigest(_ tx: inout TransactionBlock) async throws -> String {
        tx.setSenderIfNotSet(sender: try self.getAddress())
        return try await tx.getDigest(self.provider)
    }
    
    public func getTransactionBlockDigest(_ tx: inout Data) -> String {
        return TransactionBlockDataBuilder.getDigestFromBytes(bytes: tx)
    }
    
    public func dryRunTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> TransactionBlockResponse {
        transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
        let dryRunTxBytes = try await transactionBlock.build(self.provider)
        return try await self.provider.dryRunTransactionBlock([UInt8](dryRunTxBytes))
    }
    
    public func dryRunTransactionBlock(_ transactionBlock: String) async throws -> TransactionBlockResponse {
        guard let dryRunTxBytes = Data.fromBase64(transactionBlock) else { throw SuiError.notImplemented }
        return try await self.provider.dryRunTransactionBlock([UInt8](dryRunTxBytes))
    }
    
    public func dryRunTransactionBlock(_ transactionBlock: Data) async throws -> TransactionBlockResponse {
        return try await self.provider.dryRunTransactionBlock([UInt8](transactionBlock))
    }
    
    public func getGasCostEstimation(_ transactionBlock: inout TransactionBlock) async throws -> BigInt {
        let txEffects = try await self.dryRunTransactionBlock(&transactionBlock)
        guard let gasEstimation = TransactionFunctions.getTotalGasUsedUpperBound(txEffects) else {
            throw SuiError.notImplemented
        }
        return gasEstimation
    }
}

public enum IntentScope: Int {
    case TransactionData
    case TransactionEffects
    case CheckpointSummary
    case PersonalMessage
}

public enum IntentVersion: Int {
    case V0
}

public enum AppId: Int {
    case Sui
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
    guard let pubKeyData = Data(base64Encoded: pubKey) else { throw SuiError.notImplemented }
    guard let encryptionType = Signature.SIGNATURE_SCHEME_TO_FLAG[signatureScheme.rawValue] else { throw SuiError.notImplemented }
    var serializedSignature = Data(count: signature.signature.count + pubKeyData.count)
    serializedSignature[0] = encryptionType
    serializedSignature[1..<signature.signature.count] = signature.signature
    serializedSignature[1+signature.signature.count..<1+signature.signature.count+pubKeyData.count] = pubKeyData

    return serializedSignature.base64EncodedString()
}
