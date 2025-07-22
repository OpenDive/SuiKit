//
//  Intent.swift
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

final class GovernanceTest: XCTestCase {
    var toolBox: TestToolbox?
    let defaultStakeAmount = 1_000_000_000
    var stateObjectId: String = ""

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.stateObjectId = try Inputs.normalizeSuiAddress(value: "0x5")
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    private func addStake(_ client: SuiProvider, _ account: Account) async throws -> SuiTransactionBlockResponse {
        let coins = try await client.getCoins(account: try account.publicKey.toSuiAddress(), coinType: "0x2::sui::SUI")
        let system = try await client.info()
        let activeValidator = system["activeValidators"].arrayValue[0]["suiAddress"].stringValue
        var tx = try TransactionBlock()
        let coinsTx = try tx.splitCoin(coin: tx.gas, amounts: [tx.pure(value: .number(UInt64(defaultStakeAmount)))])
        _ = try tx.moveCall(
            target: "0x3::sui_system::request_add_stake",
            arguments: [
                tx.object(id: stateObjectId).toTransactionArgument(),
                coinsTx,
                .input(tx.pure(value: .address(try AccountAddress.fromHex(activeValidator))))
            ]
        )
        let coinObjects = try await client.getMultiObjects(
            ids: coins.data.map { $0.coinObjectId },
            options: SuiObjectDataOptions(showOwner: true)
        )
        try tx.setGasPayment(payments: coinObjects.map { $0.getObjectReference()! })
        return try await client.signAndExecuteTransactionBlock(
            transactionBlock: &tx,
            signer: account,
            options: SuiTransactionBlockResponseOptions(showEffects: true)
        )
    }

    func testThatRequestToAddStakesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        let result = try await self.addStake(toolBox.client, toolBox.account)
        guard result.effects?.status.status == .success else {
            XCTFail("Transaction Failed")
            return
        }
    }

    func testThatGettingDelegatedStakesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        _ = try await self.addStake(toolBox.client, toolBox.account)
        let stakes = try await toolBox.client.getStakes(owner: try toolBox.address())
        let stakesById = try await toolBox.client.getStakesByIds(
            stakes: [stakes[0].stakes[0].getStakeObject().stakeSuiId]
        )
        XCTAssertGreaterThan(stakes.count, 0)
        XCTAssertEqual(stakesById[0].stakes[0], stakes[0].stakes[0])
    }

    func testThatFetchingValidatorsFunctionsAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let committeeInfo = try await toolBox.client.getCommitteeInfo(epoch: "0")
        XCTAssertGreaterThan(committeeInfo.validators.count, 0)
    }

    func testThatGettingLatestSuiSystemStateWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        _ = try await toolBox.client.info()
    }
}
