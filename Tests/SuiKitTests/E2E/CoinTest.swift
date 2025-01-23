//
//  CoinTest.swift
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
        XCTAssertEqual(try Coin.getCoinStructTag(coinTypeArg: coins.data[0].coinType.toString()), suiStructTag)
    }
}
