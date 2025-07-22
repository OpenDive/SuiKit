//
//  TXBuilderTest.swift
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
import XCTest
import SwiftyJSON
@testable import SuiKit

// Note: Setup() has to be called for each test.
final class TXBuilderTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?
    var publishTxn: JSON?
    var sharedObjectId: String?

    var suiClockObjectId: String = ""

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        let packageResult = try await self.fetchToolBox().publishPackage("serializer")
        self.packageId = packageResult.packageId
        guard let createdObjects = packageResult.publishedTx.effects?.created else { throw SuiError.notImplemented }
        let sharedObject = createdObjects.filter { object in
            switch object.owner {
            case .shared:
                return true
            default:
                return false
            }
        }
        self.sharedObjectId = sharedObject[0].reference.objectId
        self.suiClockObjectId = try Inputs.normalizeSuiAddress(value: "0x6")
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
        try tx.setSenderIfNotSet(sender: try account.publicKey.toSuiAddress())
        let localDigest = try await tx.getDigest(client)
        let options = SuiTransactionBlockResponseOptions(showEffects: true)
        var result = try await client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: account,
            options: options
        )
        result = try await self.fetchToolBox().client.waitForTransaction(tx: localDigest, options: options)
        XCTAssertEqual(localDigest, result.digest)
        guard result.effects?.status.status == .success else {
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
            coin: tx.object(id: coin0.coinObjectId).toTransactionArgument(),
            amounts: [tx.pure(value: .number(UInt64(toolBox.defaultGasBudget * 2)))]
        )
        _ = try tx.transferObject(objects: [coin], address: try toolBox.address())
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

        _ = try tx.mergeCoin(
            destination: tx.object(id: coin0.coinObjectId).toTransactionArgument(),
            sources: [tx.object(id: coin1.coinObjectId).toTransactionArgument()]
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

        _ = try tx.moveCall(
            target: "0x2::pay::split",
            arguments: [
                tx.object(id: coin0.coinObjectId).toTransactionArgument(),
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
        _ = try tx.transferObject(objects: [coin], address: toolBox.defaultRecipient)
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
        _ = try tx.transferObject(objects: [tx.gas], address: toolBox.defaultRecipient)
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
        _ = try tx.transferObject(
            objects: [tx.object(id: coin0.coinObjectId).toTransactionArgument()],
            address: toolBox.defaultRecipient
        )
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatMoveSharedObjectCallWithMixedUsageOfMutableAndImmutableReferencesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::value",
            arguments: [tx.object(id: try self.fetchSharedObjectId()).toTransactionArgument()]
        )
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::set_value",
            arguments: [tx.object(id: try self.fetchSharedObjectId()).toTransactionArgument()]
        )
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }

    func testThatImmutableClockFunctionsAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::use_clock",
            arguments: [tx.object(id: suiClockObjectId).toTransactionArgument()]
        )
        try await self.validateTransaction(
            client: toolBox.client,
            account: toolBox.account,
            tx: &tx
        )
    }
}
