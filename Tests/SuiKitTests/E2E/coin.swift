//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/9/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class CoinTest: XCTestCase {
    func testThatCoinUtilityWorksAsIntended() async throws {
        let toolbox = try await TestToolbox(true)
        let coins = try await toolbox.getCoins()

        XCTAssertGreaterThan(coins.data.count, 0)
    }

    func testThatGetCoinStructTagWorksAsIntended() async throws {
        let toolbox = try await TestToolbox(true)
        let suiStructTag = SuiMoveNormalizedStructType(
            address: try AccountAddress.fromHex(try Inputs.normalizeSuiAddress(value: "0x2")),
            module: "sui",
            name: "SUI",
            typeArguments: []
        )
        let coins = try await toolbox.getCoins()
        XCTAssertEqual(try Coin.getCoinStructTag(coinTypeArg: coins.data[0].coinType), suiStructTag)
    }
}
