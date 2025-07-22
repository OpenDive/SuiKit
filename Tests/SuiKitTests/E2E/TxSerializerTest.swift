//
//  TxSerializerTest.swift
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

final class TxSerializerTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?
    var publishTxn: SuiTransactionBlockResponse?
    var sharedObjectId: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        let packageResult = try await self.fetchToolBox().publishPackage("serializer")
        self.packageId = packageResult.packageId
        self.publishTxn = packageResult.publishedTx
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

    private func fetchPublishedTx() throws -> SuiTransactionBlockResponse {
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

    private func serializeAndDeserialize(tx: inout TransactionBlock, mutable: [Bool]) async throws {
        let toolBox = try self.fetchToolBox()
        try tx.setSender(sender: try toolBox.address())
        let transactionBlockBytes = try await tx.build(toolBox.client)
        guard let deserialiZedTxnBuilder = TransactionBlockDataBuilder(bytes: transactionBlockBytes) else {
            XCTFail("Failed to deserialize message")
            return
        }
        let mutableCompare = deserialiZedTxnBuilder.builder.inputs.filter { input in
            switch input.value {
            case .callArg(let input):
                return input.getSharedObjectInput() != nil
            default:
                return false
            }
        }.map { input in
            switch input.value {
            case .callArg(let input):
                return input.isMutableSharedObjectInput()
            default:
                return false
            }
        }
        XCTAssertEqual(mutableCompare, mutable)
        let reserializedTx = try TransactionBlock(deserialiZedTxnBuilder)
        let reserializedTxnBytes = try await reserializedTx.build(toolBox.client)
        XCTAssertEqual(reserializedTxnBytes, transactionBlockBytes)
    }

    func testThatMoveSharedObjectCallWithImmutableReferenceWorksAsIntended() async throws {
        var tx = try TransactionBlock()
        _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::value",
            arguments: [
                tx.object(id: try self.fetchSharedObjectId()).toTransactionArgument()
            ]
        )
        try await self.serializeAndDeserialize(tx: &tx, mutable: [false])
    }

    func testThatMoveSharedObjectCallWithMixedUsageOfMutableAndImmutableReferencesWillDeserializeAsIntended() async throws {
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
        try await self.serializeAndDeserialize(tx: &tx, mutable: [true])
    }

    func testThatTransactionsWithExpirationsWillDeserializeCorrectly() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        var tx = try TransactionBlock()
        tx.setExpiration(expiration: .epoch(100))
        try await self.serializeAndDeserialize(tx: &tx, mutable: [])
    }
}
