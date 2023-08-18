//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/18/23.
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
        let gasObjects = try await toolBox.client.getOwnedObjects(try toolBox.address())
        XCTAssertGreaterThan(gasObjects.data.count, 0)
    }

    func testThatGettingAnObjectWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let gasObjects = try await toolBox.getCoins()
        XCTAssertGreaterThan(gasObjects.data.count, 0)
        try await gasObjects.data.asyncForEach { gasCoin in
            let details = gasCoin.toSuiObjectData()
            let coinObject = try await toolBox.client.getObject(
                details.objectId,
                SuiObjectDataOptions(showType: true)
            )
            XCTAssertEqual(coinObject.data?.type, "0x2::coin::Coin<0x2::sui::SUI>")
        }
    }

    func testThatGettingObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let gasObjects = try await toolBox.getCoins()
        XCTAssertGreaterThan(gasObjects.data.count, 0)
        let gasObjectIds = gasObjects.data.map { $0.coinObjectId }
        let objectInfos = try await toolBox.client.getMultiObjects(
            gasObjectIds,
            SuiObjectDataOptions(showType: true)
        )
        XCTAssertEqual(gasObjects.data.count, objectInfos.count)

        objectInfos.forEach { object in
            XCTAssertEqual(object.data?.type, "0x2::coin::Coin<0x2::sui::SUI>")
        }
    }

    func testThatHandlingNonExistingOldObjectsThrowsAnError() async throws {
        let toolBox = try self.fetchToolBox()
        let result = try await toolBox.client.tryGetPastObject(
            id: normalizeSuiAddress(value: "0x9999"),
            version: 0
        )
        XCTAssertEqual(result?.status(), "ObjectNotExists")
    }

    func testThatHandlingLiveVersionsForOldObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(try toolBox.address(), "0x2::sui::SUI")).data
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            version: Int(data[0].version) ?? 0
        )
        XCTAssertEqual(result?.status(), "VersionFound")
    }

    func testThatHandlingLiveVersionsTooHighForOldObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(try toolBox.address(), "0x2::sui::SUI")).data
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            version: (Int(data[0].version) ?? 0) + 1
        )
        XCTAssertEqual(result?.status(), "VersionTooHigh")
    }

    func testThatHandlingLiveVersionsThatDontExistForOldObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(try toolBox.address(), "0x2::sui::SUI")).data
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            // NOTE: This works because we know that this is a fresh coin that hasn't been modified:
            version: (Int(data[0].version) ?? 0) - 1
        )
        XCTAssertEqual(result?.status(), "VersionNotFound")
    }

    func testThatFindingOldVersionsOfObjectsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let data = (try await toolBox.client.getCoins(try toolBox.address(), "0x2::sui::SUI")).data
        var tx = try TransactionBlock()
        // Transfer the entire gas object:
        let _ = try tx.transferObject(
            objects: [tx.gas],
            address: normalizeSuiAddress(value: "0x2")
        )
        let _ = try await toolBox.client.signAndExecuteTransactionBlock(&tx, toolBox.account)
        let result = try await toolBox.client.tryGetPastObject(
            id: data[0].coinObjectId,
            // NOTE: This works because we know that this is a fresh coin that hasn't been modified:
            version: Int(data[0].version) ?? 0
        )
        XCTAssertEqual(result?.status(), "VersionFound")
    }
}
