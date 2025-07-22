//
//  IdEntryArgsTest.swift
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

final class IdEntryArgsTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    let defaultAddress = "0x000000000000000000000000c2b5625c221264078310a084df0a3137956d20ee"

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.packageId = try await self.fetchToolBox().publishPackage("id-entry-args").packageId
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

    func testThatIdAsArgsToEntryFunctionWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::test::test_id",
            arguments: [
                .input(
                    tx.pure(value: .address(try AccountAddress.fromHex(self.defaultAddress)))
                )
            ]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: toolBox.account,
            options: SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard result.effects?.status.status == .success else {
            XCTFail("Transaction Failed")
            return
        }
    }

    func testThatNonMutableIdAsArgsToEntryFunctionWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::test::test_id_non_mut",
            arguments: [
                .input(
                    tx.pure(value: .address(try AccountAddress.fromHex(self.defaultAddress)))
                )
            ]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: toolBox.account,
            options: SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard result.effects?.status.status == .success else {
            XCTFail("Transaction Failed")
            return
        }
    }
}
