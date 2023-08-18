//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/18/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class ReadEventTest: XCTestCase {
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

    func testThatGettingAllEventsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let allEvents = try await toolBox.client.queryEvents()
        XCTAssertGreaterThan(allEvents.data.count, 0)
    }

    func testThatGettingAllEventsWithPageWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let page1 = try await toolBox.client.queryEvents(limit: 2)
        XCTAssertNotEqual(page1.nextCursor.eventSeq, "")
        XCTAssertNotEqual(page1.nextCursor.txDigest, "")
    }

    func testThatGettingEventsBySenderPaginatedWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let query1 = try await toolBox.client.queryEvents(
            query: .sender(try toolBox.address()),
            limit: 2
        )
        XCTAssertEqual(query1.data.count, 0)
    }
}
