//
//  File.swift
//
//
//  Created by Marcus Arnett on 6/16/23.
//

import Foundation
import Blake2

public struct RawSigner: SignerWithProviderProtocol {
    public var provider: SuiProvider
    public var faucetProvider: FaucetClient
    
    public var wallet: Wallet
    
    public init(wallet: Wallet, provider: SuiProvider) {
        self.provider = provider
        self.faucetProvider = FaucetClient(connection: provider.connection)
        
        self.wallet = wallet
    }
    
    public func getAddress() throws -> String {
        return try wallet.account.publicKey().description
    }
    
    // TODO: Implement SignData function
    public func signData(data: Data) throws -> String {
        let pubKey = try self.getAddress()
        let digest = try Blake2.hash(.b2b, size: 32, data: data)
        let signature = try self.wallet.account.privateKey.sign(data: digest)
        // TODO: Implement protocol typing for signature schemes
//        let signatureScheme =
        return ""
    }
    
    public func connect(provider: SuiProvider) throws -> RawSigner {
        return RawSigner(wallet: self.wallet, provider: provider)
    }
    
    public func requestSuiFromFaucet(_ address: String) async throws -> FaucetCoinInfo {
        try await self.faucetProvider.funcAccount(address)
    }
    
    public func signMessage(_ input: Data) throws -> SignedMessage {
        let signature = try self.signData(data: messageWithIntent(.PersonalMessage, input))
        return SignedMessage(messageBytes: B64.toB64([UInt8](input)), signature: signature)
    }
    
    public func prepareTransactionBlock(_ transactionBlock: inout TransactionBlock) async throws -> Data {
        transactionBlock.setSenderIfNotSet(sender: try self.getAddress())
        return try await transactionBlock.build(self.provider)
    }
    
    public func signTransactionBlock(transactionBlock: inout TransactionBlock) async throws -> SignedTransaction {
        let txBlockBytes = try await self.prepareTransactionBlock(&transactionBlock)
        let intentMessage = messageWithIntent(.TransactionData, txBlockBytes)
        let signature = try self.signMessage(intentMessage)
        
        return SignedTransaction(
            transactionBlockBytes: B64.toB64([UInt8](txBlockBytes)),
            signature: signature
        )
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

public func messageWithIntent(_ scope: IntentScope, _ message: Data) -> Data {
    let intent = intentWithScope(scope)
    let intentData = withUnsafeBytes(of: intent) { Data($0) }
    var intentMessage = Data(capacity: intentData.count + message.count)
    intentMessage.append(intentData)
    intentMessage.append(message)
    return intentMessage
}
