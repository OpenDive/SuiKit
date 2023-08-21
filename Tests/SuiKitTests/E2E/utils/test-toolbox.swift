//
//  test-toolbox.swift
//  
//
//  Created by Marcus Arnett on 8/8/23.
//

import Foundation
import SuiKit
import SwiftyJSON

internal class TestToolbox {
    let defaultGasBudget = 10_000_000
    let defaultSendAmount = 1_000
    let defaultRecipient = "0x0c567ffdf8162cb6d51af74be0199443b92e823d4ba6ced24de5c6c463797d46"

    let account: Account
    let client: SuiProvider

    init(account: Account, client: SuiProvider = SuiProvider(connection: LocalnetConnection()), _ needsFunds: Bool = true) async throws {
        self.account = account
        self.client = client

        if needsFunds { try await self.setup() }
    }

    init(_ needsFunds: Bool = true) async throws {
        self.account = try Account()
        self.client = SuiProvider(connection: LocalnetConnection())
        if needsFunds { try await self.setup() }
    }

    func address() throws -> String {
        return try self.account.publicKey.toSuiAddress()
    }

    func getAllCoins() async throws -> PaginatedCoins {
        return try await self.client.getAllCoins(account: self.account.publicKey)
    }

    func getCoins() async throws -> PaginatedCoins {
        return try await self.client.getCoins(
            account: try self.account.publicKey.toSuiAddress(),
            coinType: "0x2::sui::SUI"
        )
    }

    func getActiveValidators() async throws -> [JSON] {
        return try await self.client.info()["SuiValidatorSummary"].arrayValue
    }

    func publishPackage(_ name: String) async throws -> PublishedPackage {
        let fileData = try self.getModule(name)

        var txBlock = try TransactionBlock()
        let cap = try txBlock.publish(
            modules: fileData["modules"].arrayObject as! [String],
            dependencies: fileData["dependencies"].arrayObject as! [String]
        )

        let _ = try txBlock.transferObject(objects: [cap], address: try self.address())
        let options = SuiTransactionBlockResponseOptions(
            showEffects: true,
            showObjectChanges: true
        )
        var publishTxBlock = try await self.client.signAndExecuteTransactionBlock(
            transactionBlock: &txBlock,
            signer: self.account,
            options: options
        )
        publishTxBlock = try await self.client.waitForTransaction(tx: publishTxBlock.digest, options: options)

        guard 
            publishTxBlock.effects?.status.status == .success,
            let objectChanges = publishTxBlock.objectChanges
        else {
            throw SuiError.notImplemented
        }

        let packageId = objectChanges.compactMap {
            switch $0 {
            case .published(let published):
                return published
            default:
                return nil
            }
        }[0].packageId.replacingOccurrences(of: "^(0x)(0+)", with: "0x", options: .regularExpression)

        print("Published package \(packageId) from address \(try self.address()).")

        return PublishedPackage(packageId: packageId, publishedTx: publishTxBlock)
    }

    func upgradePackage(_ packageId: String, _ capId: String, _ name: String) async throws {
        let fileData = try self.getModule(name)

        var txBlock = try TransactionBlock()
        let cap = try txBlock.object(value: capId)
        let ticket = try txBlock.moveCall(
            target: "0x2::package::authorize_upgrade",
            arguments: [.input(cap)]
        )

        let receipt = try txBlock.upgrade(
            modules: fileData["modules"].arrayObject as! [Data],
            dependencies: fileData["dependencies"].arrayObject as! [String],
            packageId: packageId,
            ticket: ticket
        )

        let _ = try txBlock.moveCall(
            target: "0x2::package::commit_upgrade",
            arguments: [.input(cap), receipt]
        )

        let publishTxBlock = try await self.client.signAndExecuteTransactionBlock(
            transactionBlock: &txBlock,
            signer: self.account,
            options: SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )

        guard publishTxBlock.effects?.status.status == .success else {
            throw SuiError.notImplemented
        }
    }

    func getRandomAddresses(_ n: Int) throws -> [String] {
        return try (0..<n).map { _ in try Account().publicKey.toSuiAddress() }
    }

    func paySui(
        _ numRecipients: Int = 1,
        _ recipients: [String]? = nil,
        _ amounts: [Int]? = nil,
        _ coinId: String? = nil
    ) async throws -> SuiTransactionBlockResponse {
        var txBlock = try TransactionBlock()

        let recipientsTx = try recipients ?? self.getRandomAddresses(numRecipients)
        let amountsTx = amounts ?? (0..<numRecipients).map { _ in self.defaultSendAmount }

        guard recipientsTx.count == amountsTx.count else { throw SuiError.notImplemented }

        var coinIdTx = coinId
        if coinIdTx == nil {
            coinIdTx = try await self.client.getCoins(
                account: try self.account.publicKey.toSuiAddress(),
                coinType: "0x2::sui::SUI"
            ).data[0].coinObjectId
        }
        guard let coinIdTx = coinIdTx else { throw SuiError.notImplemented }

        try recipientsTx.enumerated().forEach { (idx, recipient) in
            let coin = try txBlock.splitCoin(
                coin: .input(txBlock.object(value: coinIdTx)),
                amounts: [
                    txBlock.pure(
                        value: .number(
                            UInt64(amountsTx[idx])
                        )
                    )
                ]
            )
            let _ = try txBlock.transferObject(objects: [coin], address: recipient)
        }

        let publishTxBlock = try await self.client.signAndExecuteTransactionBlock(
            transactionBlock: &txBlock,
            signer: self.account,
            options: SuiTransactionBlockResponseOptions(
                showEffects: true,
                showObjectChanges: true
            )
        )

        guard publishTxBlock.effects?.status.status == .success else {
            throw SuiError.notImplemented
        }

        return publishTxBlock
    }

    func executePaySuiNTimes(
        _ nTimes: Int,
        _ numRecipientsPerTxn: Int = 1,
        _ recipients: [String]? = nil,
        _ amounts: [Int]? = nil
    ) async throws -> [SuiTransactionBlockResponse] {
        let options = SuiTransactionBlockResponseOptions(showEffects: true, showObjectChanges: true)
        var txns: [SuiTransactionBlockResponse] = []
        for _ in (0..<nTimes) {
            var txResponse = try await self.paySui(numRecipientsPerTxn, recipients, amounts)
            txResponse = try await self.client.waitForTransaction(tx: txResponse.digest, options: options)
            txns.append(txResponse)
        }
        return txns
    }

    private func getModule(_ name: String) throws -> JSON {
        guard let fileUrl = Bundle.test.resourceURL?.appending(component: "Resources/\(name).json") else {
            throw NSError(domain: "package is missing", code: -1)
        }
        guard let fileCompiledData = try? Data(contentsOf: fileUrl) else {
            throw NSError(domain: "package is corrupted", code: -1)
        }
        return JSON(fileCompiledData)
    }

    internal func setup() async throws {
        var isInitializing = true
        while isInitializing {
            do {
                let faucet = FaucetClient(connection: self.client.connection)
                let _ = try await faucet.funcAccount(try self.account.publicKey.toSuiAddress())
                isInitializing = false
            } catch {
                if let error = error as? SuiError, error == .FaucetRateLimitError {
                    isInitializing = false
                    throw SuiError.FaucetRateLimitError
                }
                print("Retrying requesting from faucet...")
                try await Task.sleep(nanoseconds: 60_000_000_000)
            }
        }
    }
}

internal struct PublishedPackage {
    internal let packageId: String
    internal let publishedTx: SuiTransactionBlockResponse
}
