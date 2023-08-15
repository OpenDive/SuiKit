//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/14/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class GovernanceTest: XCTestCase {
    var toolBox: TestToolbox?
    let defaultStakeAmount = 1_000_000_000

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
    
    private func addStake(_ client: SuiProvider, _ account: Account) async throws {
//        let coins = try await client.getCoins()
    }

    func testThatRequestToAddStakesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        
    }
}
