//
//  TestToolbox.swift
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
import SwiftyJSON

internal class TestToolbox {
    let defaultGasBudget = 10_000_000
    let defaultSendAmount = 1_000
    let defaultRecipient = "0x0c567ffdf8162cb6d51af74be0199443b92e823d4ba6ced24de5c6c463797d46"

    let account: Account
    let client: SuiProvider
    let graphQLProvider: GraphQLSuiProvider

    init(
        account: Account,
        client: SuiProvider = SuiProvider(connection: LocalnetConnection()),
        graphQLClient: GraphQLSuiProvider = GraphQLSuiProvider(connection: LocalnetConnection()),
        _ needsFunds: Bool = true
    ) async throws {
        self.account = account
        self.client = client
        self.graphQLProvider = graphQLClient

        if needsFunds { try await self.setup() }
    }

    init(_ needsFunds: Bool = true) async throws {
        self.account = try Account()
        self.client = SuiProvider(connection: LocalnetConnection())
        self.graphQLProvider = GraphQLSuiProvider(connection: LocalnetConnection())
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

        _ = try txBlock.transferObject(objects: [cap], address: try self.address())
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
                coin: txBlock.object(objectArgument: .string(coinIdTx)).toTransactionArgument(),
                amounts: [
                    txBlock.pure(
                        value: .number(
                            UInt64(amountsTx[idx])
                        )
                    )
                ]
            )
            _ = try txBlock.transferObject(objects: [coin], address: recipient)
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

    func executeTransactionBlock(txb: inout TransactionBlock) async throws -> SuiTransactionBlockResponse {
        let resp = try await self.client.signAndExecuteTransactionBlock(transactionBlock: &txb, signer: self.account, options: SuiTransactionBlockResponseOptions(showEffects: true, showEvents: true, showObjectChanges: true))
        guard resp.effects?.status.status == .success else { throw SuiError.notImplemented }
        return resp
    }

    func getCreatedObjectIdByType(res: SuiTransactionBlockResponse, type: String) throws -> String {
        guard let objectChanges = res.objectChanges else { throw SuiError.notImplemented }
        let results: [SuiObjectChangeCreated] = objectChanges.compactMap({ change in
            guard
                case .created(let created) = change,
                created.objectType.hasSuffix(type)
            else { return nil }
            return created
        })
        if results.isEmpty { throw SuiError.customError(message: "Empty message") }
        return results[0].objectId
    }

    func getPublisherObject() async throws -> String {
        let res = try await self.client.getOwnedObjects(owner: try self.address(), filter: .structType("0x2::package::Publisher"))
        let publisherObj = res.data[0].data?.objectId
        return publisherObj ?? ""
    }

    func setup() async throws {
        var isInitializing = true
        while isInitializing {
            do {
                let faucet = FaucetClient(connection: self.client.connection)
                _ = try await faucet.funcAccount(try self.account.publicKey.toSuiAddress())
                isInitializing = false
            } catch {
                if error.localizedDescription.contains("limit") {
                    isInitializing = false
                    throw SuiError.customError(message: "Faucet rate limit error. Please try again later.")
                }
                print("Retrying requesting from faucet...")
                try await Task.sleep(nanoseconds: 60_000_000_000)
            }
        }
    }

    func faucetAccount(to suiAddress: String, andIsWaitingForFaucet waitForFaucet: Bool = false) async throws {
        let faucet = FaucetClient(connection: self.client.connection)
        let txFaucet = try await faucet.funcAccount(suiAddress)
        if waitForFaucet {
            guard let coinsSent = txFaucet.coinsSent, !coinsSent.isEmpty else {
                throw SuiError.customError(message: "No coins were sent")
            }
            _ = try await self.client.waitForTransaction(tx: coinsSent[0].transferTxDigest)
        }
    }

    func publishKioskExtensions() async throws -> String {
        let result = try await self.publishPackage("kiosk")
        return result.packageId
    }

    private func getModule(_ name: String) throws -> JSON {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            guard let fileUrl = Bundle.test.resourceURL?.appending(component: "\(name).json") else {
                throw NSError(domain: "package is missing", code: -1)
            }
            guard let fileCompiledData = try? Data(contentsOf: fileUrl) else {
                throw NSError(domain: "package is corrupted", code: -1)
            }
            return JSON(fileCompiledData)
        } else {
            throw SuiError.notImplemented
        }
    }
}
