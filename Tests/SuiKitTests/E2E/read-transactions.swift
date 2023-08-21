//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/20/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class ReadTransactionTest: XCTestCase {
    var toolBox: TestToolbox?
    var transactions: [SuiTransactionBlockResponse] = []

    let numTransactions = 10

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    private func initializePaySui() async throws {
        self.transactions = try await self.fetchToolBox().executePaySuiNTimes(self.numTransactions)
    }

    private func setupTransaction(_ toolBox: TestToolbox) async throws -> SuiTransactionBlockResponse {
        var tx = try TransactionBlock()
        let coin = try tx.splitCoin(coin: tx.gas, amounts: [tx.pure(value: .number(1))])
        let _ = try tx.transferObject(objects: [coin], address: try toolBox.address())
        return try await toolBox.client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: toolBox.account,
            requestType: .waitforEffectsCert
        )
    }

    func testThatGettingTotalTransactionsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let numTransactions = try await toolBox.client.getTotalTransactionBlocks()
        XCTAssertGreaterThan(numTransactions, 0)
    }

    func testThatWaitingForTransactionBlocksWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        var response = try await self.setupTransaction(toolBox)
        response = try await toolBox.client.waitForTransaction(tx: response.digest)
        guard response.timestampMs != nil else {
            XCTFail("Transaction Failed")
            return
        }
    }

    func testThatGettingTransactionsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await self.initializePaySui()
        let digest = self.transactions[0].digest
        let tx = try await toolBox.client.getTransactionBlock(digest: digest)
        XCTAssertEqual(tx.digest, digest)
    }

    func testThatMultiGetPayTransactionWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await self.initializePaySui()
        let digests = self.transactions.map { $0.digest }
        let txns = try await toolBox.client.multiGetTransactionBlocks(
            digests: digests,
            options: SuiTransactionBlockResponseOptions(showBalanceChanges: true)
        )
        txns.enumerated().forEach { (idx, tx) in
            XCTAssertEqual(tx.digest, digests[idx])
            XCTAssertEqual(tx.balanceChanges?.count, 2)
        }
    }

    func testThatQueryTransactionsWithOptionsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await self.initializePaySui()
        let options = SuiTransactionBlockResponseOptions(
            showInput: true,
            showEffects: true,
            showEvents: true,
            showObjectChanges: true,
            showBalanceChanges: true
        )
        let resp = try await toolBox.client.queryTransactionBlocks(
            limit: 1,
            options: options
        )
        let digest = resp.data[0].digest
        let response2 = try await toolBox.client.getTransactionBlock(
            digest: digest,
            options: options
        )
        XCTAssertEqual(digest, response2.digest)
    }

    func testThatFetchingAllOfTheTransactionsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await self.initializePaySui()
        let allTransactions = try await toolBox.client.queryTransactionBlocks(limit: 10)
        XCTAssertGreaterThan(allTransactions.data.count, 0)
    }

    func testThatGenesisForTransactionsExists() async throws {
        let toolBox = try self.fetchToolBox()
        try await self.initializePaySui()
        let allTransactions = try await toolBox.client.queryTransactionBlocks(limit: 1, order: .ascending)
        let resp = try await toolBox.client.getTransactionBlock(
            digest: allTransactions.data[0].digest,
            options: SuiTransactionBlockResponseOptions(showInput: true)
        )
        let txKind = resp.transaction?.data.transaction
        XCTAssertTrue(txKind?.kind() == .genesis)
    }
}