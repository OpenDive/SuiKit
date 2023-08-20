//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/17/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class ProtocolConfigTest: XCTestCase {
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

    func testThatFetchingProtocolConfigWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let config = try await toolBox.client.getProtocolConfig()
        XCTAssertNotEqual(config.protocolVersion, "")
    }
}
