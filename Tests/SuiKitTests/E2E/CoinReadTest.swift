//
//  CoinReadTest.swift
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

final class CoinReadTest: XCTestCase {
    var toolBox: TestToolbox?
    var publishToolBox: TestToolbox?
    var packageId: String?
    var testType: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.publishToolBox = try await TestToolbox(true)
        self.packageId = try await self.fetchPublisherToolBox().publishPackage("coin-metadata").packageId
        self.testType = "\(try self.fetchPackageId())::test::TEST"
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    private func fetchPublisherToolBox() throws -> TestToolbox {
        guard let publishToolBox = self.publishToolBox else {
            XCTFail("Failed to get Publisher Toolbox")
            throw NSError(domain: "Failed to get Publisher Toolbox", code: -1)
        }
        return publishToolBox
    }

    private func fetchPackageId() throws -> String {
        guard let packageId = self.packageId else {
            XCTFail("Failed to get Package ID")
            throw NSError(domain: "Failed to get Package ID", code: -1)
        }
        return packageId
    }

    private func fetchTestType() throws -> String {
        guard let testType = self.testType else {
            XCTFail("Failed to get Test Type")
            throw NSError(domain: "Failed to get Test Type", code: -1)
        }
        return testType
    }

    func testThatGettingCoinWithoutTypeFunctionsAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let publisherToolBox = try self.fetchPublisherToolBox()

        let suiCoin = try await toolBox.client.getCoins(account: try toolBox.account.publicKey.toSuiAddress())
        XCTAssertEqual(suiCoin.data.count, 5)

        let testCoins = try await publisherToolBox.client.getCoins(
            account: try publisherToolBox.account.publicKey.toSuiAddress(),
            coinType: try self.fetchTestType()
        )
        XCTAssertEqual(testCoins.data.count, 2)

        let allCoins = try await toolBox.client.getAllCoins(account: toolBox.account.publicKey)
        XCTAssertEqual(allCoins.data.count, 5)
        XCTAssertFalse(allCoins.hasNextPage!)

        let publisherAllCoins = try await publisherToolBox.client.getAllCoins(account: publisherToolBox.account.publicKey)
        XCTAssertEqual(publisherAllCoins.data.count, 3)
        XCTAssertFalse(publisherAllCoins.hasNextPage!)

        let someSuiCoins = try await toolBox.client.getCoins(
            account: try toolBox.account.publicKey.toSuiAddress(),
            coinType: nil,
            cursor: nil,
            limit: 3
        )
        XCTAssertEqual(someSuiCoins.data.count, 3)
        XCTAssertTrue(someSuiCoins.hasNextPage!)
    }

    func testThatGettingBalanceWithAndWithoutTypeWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let publisherToolBox = try self.fetchPublisherToolBox()

        let suiBalance = try await toolBox.client.getBalance(account: toolBox.account.publicKey)
        XCTAssertEqual(suiBalance.coinType, try StructTag.fromStr("0x2::sui::SUI"))
        XCTAssertEqual(suiBalance.coinObjectCount, 5)
        XCTAssertGreaterThan(Int(suiBalance.totalBalance) ?? 0, 0)

        let testBalance = try await publisherToolBox.client.getBalance(
            account: publisherToolBox.account.publicKey,
            coinType: try self.fetchTestType()
        )
        XCTAssertEqual(testBalance.coinType, try StructTag.fromStr(try self.fetchTestType()))
        XCTAssertEqual(testBalance.coinObjectCount, 2)
        XCTAssertEqual(Int(testBalance.totalBalance) ?? -1, 11)

        let allBalances = try await publisherToolBox.client.getAllBalances(account: publisherToolBox.account)
        XCTAssertEqual(allBalances.count, 2)
    }

    func testThatRetrievingTotalSupplyWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let testSupply = try await toolBox.client.totalSupply(try self.fetchTestType())
        XCTAssertEqual(Int(testSupply), 11)
    }
}
