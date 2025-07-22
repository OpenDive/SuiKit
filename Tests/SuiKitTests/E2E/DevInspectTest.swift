//
//  DevInspectTest.swift
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

final class DevInspectTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.packageId = try await self.fetchToolBox().publishPackage("serializer").packageId
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

    private func validateDevInspectTransaction(
        _ client: SuiProvider,
        _ signer: Account,
        _ transactionBlock: inout TransactionBlock,
        _ status: ExecutionStatusType
    ) async throws {
        let result = try await client.devInspectTransactionBlock(
            transactionBlock: &transactionBlock,
            sender: signer
        )
        guard status == result?.effects.status.status else {
            XCTFail("Status does not match")
            return
        }
    }

    func testThatDevInspectSplitAndTransferWorkAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        var txBlock = try TransactionBlock()
        let coin = try txBlock.splitCoin(coin: txBlock.gas, amounts: [txBlock.pure(value: .number(10))])
        _ = try txBlock.transferObject(
            objects: [coin],
            address: try toolBox.account.publicKey.toSuiAddress()
        )
        try await self.validateDevInspectTransaction(
            toolBox.client,
            toolBox.account,
            &txBlock,
            .success
        )
    }

    func testThatMoveCallsThatReturnStructsWorkAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let coins = try await toolBox.getCoins()

        var tx = try TransactionBlock()
        let coin0 = coins.data[0]
        let obj = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::return_struct",
            arguments: [.input(tx.pure(value: .string(coin0.coinObjectId)))],
            typeArguments: ["0x2::coin::Coin<0x2::sui::SUI>"]
        )

        _ = try tx.transferObject(
            objects: [obj[0]],
            address: try toolBox.account.publicKey.toSuiAddress()
        )

        try await self.validateDevInspectTransaction(
            toolBox.client,
            toolBox.account,
            &tx,
            .success
        )
    }

    func testThatVerifiesIncorrectMoveCallsWillFail() async throws {
        let toolBox = try self.fetchToolBox()
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::test_abort",
            arguments: [],
            typeArguments: []
        )

        try await self.validateDevInspectTransaction(toolBox.client, toolBox.account, &tx, .failure)
    }
}
