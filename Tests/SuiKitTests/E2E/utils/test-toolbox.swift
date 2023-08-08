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

    let account: Account
    let client: SuiProvider

    init(account: Account, client: SuiProvider = SuiProvider(connection: devnetConnection()), _ needsFunds: Bool = true) async throws {
        self.account = account
        self.client = client

        if needsFunds { try await self.setup() }
    }

    init(_ needsFunds: Bool = true) async throws {
        self.account = try Account()
        self.client = SuiProvider(connection: devnetConnection())

        if needsFunds { try await self.setup() }
    }

    func address() throws -> String {
        return try self.account.publicKey.toSuiAddress()
    }

    func getAllCoins() async throws -> PaginatedCoins {
        return try await self.client.getAllCoins(self.account.publicKey)
    }

    func getActiveValidators() async throws -> [JSON] {
        return try await self.client.info()["SuiValidatorSummary"].arrayValue
    }

    func publishPackage(_ name: String) async throws -> PublishedPackage {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw NSError(domain: "package is missing", code: -1)
        }
        guard let fileCompiledData = try? Data(contentsOf: fileUrl) else {
            throw NSError(domain: "package is corrupted", code: -1)
        }
        let fileData = JSON(fileCompiledData)

        var txBlock = TransactionBlock()
        let cap = try txBlock.publish(
            modules: fileData["modules"].arrayObject as! [Data],
            dependencies: fileData["dependencies"].arrayObject as! [String]
        )

        let _ = try txBlock.transferObject(objects: [cap], address: try self.address())

        let publishTxBlock = try await self.client.signAndExecuteTransactionBlock(
            &txBlock,
            self.account,
            SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )

        guard publishTxBlock["effects"]["status"]["status"].stringValue == "success" else {
            throw SuiError.notImplemented
        }

        let packageId = publishTxBlock["objectChanges"].arrayValue.filter {
            $0["type"].stringValue == "published"
        }[0]["packageId"]
            .stringValue
            .replacingOccurrences(of: "^(0x)(0+)", with: "0x", options: .regularExpression)

        print("Published package \(packageId) from address \(try self.address()).")

        return PublishedPackage(packageId: packageId, publishedTx: publishTxBlock)
    }

    func upgradePackage(_ packageId: String, _ capId: String, _ name: String) async throws {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw NSError(domain: "package is missing", code: -1)
        }
        guard let fileCompiledData = try? Data(contentsOf: fileUrl) else {
            throw NSError(domain: "package is corrupted", code: -1)
        }
        let fileData = JSON(fileCompiledData)

        var txBlock = TransactionBlock()
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
            &txBlock,
            self.account,
            SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )

        guard publishTxBlock["effects"]["status"]["status"].stringValue == "success" else {
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
    ) async throws -> JSON {
        var txBlock = TransactionBlock()

        let recipientsTx = try recipients ?? self.getRandomAddresses(numRecipients)
        let amountsTx = amounts ?? (0..<numRecipients).map { _ in self.defaultSendAmount }

        guard recipientsTx.count == amountsTx.count else { throw SuiError.notImplemented }

        var coinIdTx = coinId
        if coinIdTx == nil {
            coinIdTx = try await self.client.getCoins(
                try self.account.publicKey.toSuiAddress(),
                "0x2::sui::SUI"
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
            &txBlock,
            self.account,
            SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )

        guard publishTxBlock["effects"]["status"]["status"].stringValue == "success" else {
            throw SuiError.notImplemented
        }

        return publishTxBlock
    }

    func executePaySuiNTimes(
        _ nTimes: Int,
        _ numRecipientsPerTxn: Int = 1,
        _ recipients: [String]? = nil,
        _ amounts: [Int]? = nil
    ) async throws -> [JSON] {
        var txns: [JSON] = [JSON](repeating: JSON(), count: nTimes)
        for i in (0..<nTimes) {
            txns[i] = try await self.paySui(numRecipientsPerTxn, recipients, amounts)
        }
        return txns
    }

    private func setup() async throws {
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
    internal let publishedTx: JSON
}
