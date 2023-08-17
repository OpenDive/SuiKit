//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/17/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class IdEntryArgsTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

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
        let _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::test::test_id",
            arguments: [
                .input(
                    tx.pure(value: .address(try ED25519PublicKey(hexString: "0x000000000000000000000000c2b5625c221264078310a084df0a3137956d20ee")))
                )
            ]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            &tx,
            toolBox.account,
            SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Status does not match")
            return
        }
    }

    func testThatNonMutableIdAsArgsToEntryFunctionWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        var tx = try TransactionBlock()
        let _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::test::test_id_non_mut",
            arguments: [
                .input(
                    tx.pure(value: .address(try ED25519PublicKey(hexString: "0x000000000000000000000000c2b5625c221264078310a084df0a3137956d20ee")))
                )
            ]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            &tx,
            toolBox.account,
            SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Status does not match")
            return
        }
    }
}
