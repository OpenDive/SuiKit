//
//  ObjectsTest.swift
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

final class ObjectsTest: XCTestCase {
    var toolBox: TestToolbox?

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

    func testThatGettingOwnedObjectsFetchesAtLeastOneObject() async throws {
        let toolBox = try self.fetchToolBox()
        let gasObjects = try await toolBox.client.getOwnedObjects(owner: try toolBox.address())
        XCTAssertGreaterThan(gasObjects.data.count, 0)
    }

    func testThatGettingAnObjectWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let gasObjects = try await toolBox.getCoins()
        XCTAssertGreaterThan(gasObjects.data.count, 0)
        try await gasObjects.data.asyncForEach { gasCoin in
            let details = gasCoin.toSuiObjectData()
            let coinObject = try await toolBox.client.getObject(
                objectId: details.objectId,
                options: SuiObjectDataOptions(showType: true)
            )
            XCTAssertEqual(coinObject?.data?.type, "0x2::coin::Coin<0x2::sui::SUI>")
        }
    }

    func testThatGettingObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let gasObjects = try await toolBox.getCoins()
        XCTAssertGreaterThan(gasObjects.data.count, 0)
        let gasObjectIds = gasObjects.data.map { $0.coinObjectId }
        let objectInfos = try await toolBox.client.getMultiObjects(
            ids: gasObjectIds,
            options: SuiObjectDataOptions(showType: true)
        )
        XCTAssertEqual(gasObjects.data.count, objectInfos.count)

        objectInfos.forEach { object in
            XCTAssertEqual(object.data?.type, "0x2::coin::Coin<0x2::sui::SUI>")
        }
    }

    func testThatHandlingNonExistingOldObjectsThrowsAnError() async throws {
        let toolBox = try self.fetchToolBox()
        let result = try await toolBox.client.tryGetPastObject(
            id: Inputs.normalizeSuiAddress(value: "0x9999"),
            version: 0
        )
        XCTAssertEqual(result?.status(), "ObjectNotExists")
    }

    func testThatHandlingLiveVersionsForOldObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(account: try toolBox.address(), coinType: "0x2::sui::SUI")).data
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            version: Int(data[0].version) ?? 0
        )
        XCTAssertEqual(result?.status(), "VersionFound")
    }

    func testThatHandlingLiveVersionsTooHighForOldObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(account: try toolBox.address(), coinType: "0x2::sui::SUI")).data
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            version: (Int(data[0].version) ?? 0) + 1
        )
        XCTAssertEqual(result?.status(), "VersionTooHigh")
    }

    func testThatHandlingLiveVersionsThatDontExistForOldObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(account: try toolBox.address(), coinType: "0x2::sui::SUI")).data
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            // NOTE: This works because we know that this is a fresh coin that hasn't been modified:
            version: (Int(data[0].version) ?? 0) - 1
        )
        XCTAssertEqual(result?.status(), "VersionNotFound")
    }

    func testThatFindingOldVersionsOfObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(account: try toolBox.address(), coinType: "0x2::sui::SUI")).data
        var tx = try TransactionBlock()
        // Transfer the entire gas object:
        _ = try tx.transferObject(
            objects: [tx.gas],
            address: Inputs.normalizeSuiAddress(value: "0x2")
        )
        _ = try await toolBox.client.signAndExecuteTransactionBlock(transactionBlock: &tx, signer: toolBox.account)
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            // NOTE: This works because we know that this is a fresh coin that hasn't been modified:
            version: Int(data[0].version) ?? 0
        )
        XCTAssertEqual(result?.status(), "VersionFound")
    }
}
