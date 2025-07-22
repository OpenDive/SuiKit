//
//  ReadTransactionTest.swift
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
        _ = try tx.transferObject(objects: [coin], address: try toolBox.address())
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
