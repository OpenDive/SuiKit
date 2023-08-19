//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/18/23.
//

import Foundation
import XCTest
import SwiftyJSON
@testable import SuiKit

final class TxSerializerTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?
    var publishTxn: JSON?
    var sharedObjectId: String?

    override func setUp() async throws {
//        let account = try Account(accountType: .ed25519, "W8hh3ioDwgAoUlm0IXRZn6ETlcLmF07DN3RQBLCQ3N0=")
        self.toolBox = try await TestToolbox(true)
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
        let reserializedTxnBytes = try deserialiZedTxnBuilder.build()
        XCTAssertEqual(reserializedTxnBytes, transactionBlockBytes)
    }

    func testThatMoveSharedObjectCallWithImmutableReferenceWorksAsIntended() async throws {
        var tx = try TransactionBlock()
        let _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::serializer_tests::value",
            arguments: [
                .input(tx.object(value: try self.fetchSharedObjectId()))
            ]
        )
        try await self.serializeAndDeserialize(tx: &tx, mutable: [false])
    }
}
