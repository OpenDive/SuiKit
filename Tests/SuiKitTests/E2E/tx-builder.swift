//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/15/23.
//

import Foundation
import XCTest
import SwiftyJSON
@testable import SuiKit

// Note: Setup() has to be called for each test.
final class TXBuilderTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?
    var publishTxn: JSON?
    var sharedObjectId: String?

    override func setUp() async throws {
        let account = try Account(accountType: .ed25519, "W8hh3ioDwgAoUlm0IXRZn6ETlcLmF07DN3RQBLCQ3N0=")
        self.toolBox = try await TestToolbox(account: account, true)
        let packageResult = try await self.fetchToolBox().publishPackage("serializer")
        self.packageId = packageResult.packageId
        self.publishTxn = packageResult.publishedTx
        let sharedObject = packageResult.publishedTx["effects"]["created"].arrayValue.filter { object in
            return object["owner"]["Shared"]["initial_shared_version"].int != nil
        }
        self.sharedObjectId = sharedObject[0]["reference"]["objectId"].stringValue
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    private func fetchPackageId() throws -> String {
        guard let packageId = self.packageId else {
            XCTFail("Failed to get Package ID")
            throw NSError(domain: "Failed to get Package ID", code: -1)
        }
        return packageId
    }

    private func fetchPublishedTx() throws -> JSON {
        guard let publishTxn = self.publishTxn else {
            XCTFail("Failed to get Published Txn")
            throw NSError(domain: "Failed to get Published Txn", code: -1)
        }
        return publishTxn
    }

    private func fetchSharedObjectId() throws -> String {
        guard let sharedObjectId = self.sharedObjectId else {
            XCTFail("Failed to get Shared Object ID")
            throw NSError(domain: "Failed to get Shared Object ID", code: -1)
        }
        return sharedObjectId
    }

    private func validateTransaction(client: SuiProvider, account: Account, tx: inout TransactionBlock) async throws {
        tx.setSenderIfNotSet(sender: try account.publicKey.toSuiAddress())
        let localDigest = try await tx.getDigest(client)
        let result = try await client.signAndExecuteTransactionBlock(
            &tx,
            account,
            SuiTransactionBlockResponseOptions(
                showInput: false,
                showEffects: true,
                showEvents: false,
                showObjectChanges: true,
                showBalanceChanges: false
            )
        )
        try await self.fetchToolBox().client.waitForTransaction(localDigest)
        XCTAssertEqual(localDigest, result["digest"].stringValue)
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Transaction Failed")
            return
        }
    }

    func testThatSplitCoinAndTransferWorkAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        let coins = try await toolBox.getCoins()
        let coin0 = coins.data[0]
        var tx = try TransactionBlock()

        let coin = try tx.splitCoin(
            coin: .input(tx.object(value: coin0.coinObjectId)),
            amounts: [tx.pure(value: .number(UInt64(toolBox.defaultGasBudget * 2)))]
        )
        let _ = try tx.transferObject(objects: [coin], address: try toolBox.address())
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatMergeCoinWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        let coins = try await toolBox.getCoins()
        let coin0 = coins.data[0]
        let coin1 = coins.data[1]
        var tx = try TransactionBlock()

        let _ = try tx.mergeCoin(
            destination: tx.object(value: coin0.coinObjectId),
            sources: [tx.object(value: coin1.coinObjectId)]
        )

        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatMoveCallWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        let coins = try await toolBox.getCoins()
        let coin0 = coins.data[0]
        var tx = try TransactionBlock()

        let _ = try tx.moveCall(
            target: "0x2::pay::split",
            arguments: [
                .input(tx.object(value: coin0.coinObjectId)),
                .input(tx.pure(value: .number(UInt64(toolBox.defaultGasBudget * 2))))
            ],
            typeArguments: ["0x2::sui::SUI"]
        )

        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatSplitCoinAndTransferObjectAreAbleToUseGasCoinsAutomatically() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        var tx = try TransactionBlock()
        let coin = try tx.splitCoin(
            coin: tx.gas,
            amounts: [tx.pure(value: .number(1))]
        )
        let _ = try tx.transferObject(objects: [coin], address: toolBox.defaultRecipient)
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatTransferObjectsCanHandleGasCoins() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        var tx = try TransactionBlock()
        let _ = try tx.transferObject(objects: [tx.gas], address: toolBox.defaultRecipient)
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatTransferObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        var tx = try TransactionBlock()
        let coins = try await toolBox.getCoins()
        let coin0 = coins.data[0]
        let _ = try tx.transferObject(
            objects: [.input(tx.object(value: coin0.coinObjectId))],
            address: toolBox.defaultRecipient
        )
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

//    func testThatMoveSharedObjectCallWithMixedUsageOfMutableAndImmutableReferencesWorksAsIntended() async throws {
//        let toolBox = try self.fetchToolBox()
//        print("DEBUG: OBJECT ID - \(try self.fetchSharedObjectId())")
//        try await toolBox.setup()
//        var tx = try TransactionBlock()
//        let _ = try tx.moveCall(
//            target: "\(try self.fetchPackageId())::serializer_tests::value",
//            arguments: [.input(tx.object(value: try self.fetchSharedObjectId()))]
//        )
//        let _ = try tx.moveCall(
//            target: "\(try self.fetchPackageId())::serializer_tests::set_value",
//            arguments: [.input(tx.object(value: try self.fetchSharedObjectId()))]
//        )
//        try await self.validateTransaction(
//            client: toolBox.client,
//            account: toolBox.account,
//            tx: &tx
//        )
//    }
}
