//
//  coin-metadata.swift
//  
//
//  Created by Marcus Arnett on 8/8/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class CoinMetadataTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    override func setUp() async throws {
        let account = try Account(accountType: .ed25519, "W8hh3ioDwgAoUlm0IXRZn6ETlcLmF07DN3RQBLCQ3N0=")
        self.toolBox = try await TestToolbox(account: account, false)
        self.packageId = try await self.fetchToolBox().publishPackage("coin-metadata").packageId
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

    func testThatAccessingCoinMetadataFunctionsAsExpected() async throws {
        let toolBox = try self.fetchToolBox()
        let coinMetadata = try await toolBox.client.getCoinMetadata(
            "\(try self.fetchPackageId())::test::TEST"
        )

        XCTAssertEqual(coinMetadata.decimals, 2)
        XCTAssertEqual(coinMetadata.name, "Test Coin")
        XCTAssertEqual(coinMetadata.description, "Test coin metadata")
        XCTAssertNotNil(coinMetadata.iconUrl)
        XCTAssertEqual(coinMetadata.iconUrl!, "http://sui.io")
    }
}
