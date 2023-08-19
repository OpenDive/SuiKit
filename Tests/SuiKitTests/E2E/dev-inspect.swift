//
//  File.swift
//
//
//  Created by Marcus Arnett on 8/9/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class DevInspectTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    override func setUp() async throws {
        let account = try Account(accountType: .ed25519, "W8hh3ioDwgAoUlm0IXRZn6ETlcLmF07DN3RQBLCQ3N0=")
        self.toolBox = try await TestToolbox(account: account, true)
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
        let _ = try txBlock.transferObject(
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

        let _ = try tx.transferObject(
            objects: [obj],
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
        let _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::test_abort",
            arguments: [],
            typeArguments: []
        )

        try await self.validateDevInspectTransaction(toolBox.client, toolBox.account, &tx, .failure)
    }
}