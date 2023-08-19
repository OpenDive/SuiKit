//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/18/23.
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
        let _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::entry_point_vector::mint",
            arguments: [.input(tx.pure(value: .number(UInt64(val))))]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: toolBox.account,
            options: SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Status does not match")
            return ""
        }
        return result["effects"]["created"].arrayValue[0]["reference"]["objectId"].stringValue
    }

    private func destroyObjects(objects: [String], withType: Bool = false, toolBox: TestToolbox) async throws {
        var tx = try TransactionBlock()
        let vec = try tx.makeMoveVec(
            type: withType ? "\(try self.fetchPackageId())::entry_point_vector::Obj" : nil,
            objects: objects.map { try tx.object(value: $0) }
        )
        let _ = try tx.moveCall(
            target: "\(try self.fetchPackageId())::entry_point_vector::two_obj_vec_destroy",
            arguments: [vec]
        )
        let result = try await toolBox.client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: toolBox.account,
            options: SuiTransactionBlockResponseOptions(showEffects: true)
        )
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Status does not match")
            return
        }
    }

    func testThatVectorObjectsAreAbleToBeInitialized() async throws {
        let toolBox = try self.fetchToolBox()
        try await self.destroyObjects(
            objects: [
                (try await self.mintObject(val: 7, toolBox: toolBox)),
                (try await self.mintObject(val: 42, toolBox: toolBox))
            ],
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
                tx.object(value: coinIds[1]),
                tx.object(value: coinIds[2])
            ]
        )
        let _ = try tx.moveCall(
            target: "0x2::pay::join_vec",
            arguments: [
                .input(tx.object(value: coinIds[0])),
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
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Status does not match")
            return
        }
    }
}
