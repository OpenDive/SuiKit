//
//  ObjectVectorTest.swift
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

final class ObjectVectorTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.packageId = try await self.fetchToolBox().publishPackage("entry-point-vector").packageId
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

    private func mintObject(val: Int, toolBox: TestToolbox) async throws -> String {
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::entry_point_vector::mint",
            arguments: [.input(tx.pure(value: .number(UInt64(val))))]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: toolBox.account,
            options: SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard
            result.effects?.status.status == .success,
            let returnValue = result.effects?.created?[0].reference.objectId
        else {
            XCTFail("Transaction Failed")
            throw SuiError.notImplemented
        }
        return returnValue
    }

    private func destroyObjects(objects: [String], withType: Bool = false, toolBox: TestToolbox) async throws {
        var tx = try TransactionBlock()
        let vec = try tx.makeMoveVec(
            type: withType ? "\(try self.fetchPackageId())::entry_point_vector::Obj" : nil,
            objects: objects.map { try tx.object(id: $0).toTransactionArgument() }
        )
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::entry_point_vector::two_obj_vec_destroy",
            arguments: [vec]
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

    func testThatVectorObjectsAreAbleToBeInitialized() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        try await self.destroyObjects(
            objects: [
                (try await self.mintObject(val: 7, toolBox: toolBox)),
                (try await self.mintObject(val: 42, toolBox: toolBox))
            ],
            toolBox: toolBox
        )
    }

    // TODO: Figure out and implement a solution for this flanky test.
    func testThatTypeHintsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        try await self.destroyObjects(
            objects: [
                (try await self.mintObject(val: 7, toolBox: toolBox)),
                (try await self.mintObject(val: 42, toolBox: toolBox))
            ],
            withType: true,
            toolBox: toolBox
        )
    }

    func testThatRegularArgumentsAndObjectVectorArgsMixedWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        let coins = try await toolBox.getCoins()
        let coin = coins.data[3]
        let coinIds = coins.data.map { $0.coinObjectId }
        var tx = try TransactionBlock()
        let vec = try tx.makeMoveVec(
            objects: [
                tx.object(id: coinIds[1]).toTransactionArgument(),
                tx.object(id: coinIds[2]).toTransactionArgument()
            ]
        )
        _ = try tx.moveCall(
            target: "0x2::pay::join_vec",
            arguments: [
                tx.object(id: coinIds[0]).toTransactionArgument(),
                vec
            ],
            typeArguments: ["0x2::sui::SUI"]
        )
        try tx.setGasPayment(payments: [coin.toSuiObjectRef()])
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
