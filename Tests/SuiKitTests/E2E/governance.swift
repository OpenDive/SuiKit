//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/14/23.
//

import Foundation
import XCTest
import SwiftyJSON
@testable import SuiKit

final class GovernanceTest: XCTestCase {
    var toolBox: TestToolbox?
    let defaultStakeAmount = 1_000_000_000
    let stateObjectId = normalizeSuiAddress(value: "0x5")

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

    private func addStake(_ client: SuiProvider, _ account: Account) async throws -> JSON {
        let coins = try await client.getCoins(try account.publicKey.toSuiAddress(), "0x2::sui::SUI")
        let system = try await client.info()
        let activeValidator = system["activeValidators"].arrayValue[0]["suiAddress"].stringValue
        var tx = try TransactionBlock()
        let coinsTx = try tx.splitCoin(coin: tx.gas, amounts: [tx.pure(value: .number(UInt64(defaultStakeAmount)))])
        let _ = try tx.moveCall(
            target: "0x3::sui_system::request_add_stake",
            arguments: [
                .input(tx.object(value: stateObjectId)),
                coinsTx,
                .input(tx.pure(value: .address(try ED25519PublicKey(hexString: activeValidator))))
            ]
        )
        let coinObjects = try await client.getMultiObjects(
            coins.data.map { $0.coinObjectId },
            GetObject(showOwner: true)
        )
        try tx.setGasPayment(payments: coinObjects.map { $0.getObjectReference() })
        return try await client.signAndExecuteTransactionBlock(
            &tx,
            account,
            SuiTransactionBlockResponseOptions(showEffects: true)
        )
    }

    func testThatRequestToAddStakesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        try await toolBox.setup()
        let result = try await self.addStake(toolBox.client, toolBox.account)
        guard "success" == result["effects"]["status"]["status"].stringValue else {
            XCTFail("Transaction Failed")
            return
        }
    }
}
