//
//  ReadEventTest.swift
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
        XCTAssertNotEqual(page1.nextCursor!.eventSeq, "")
        XCTAssertNotEqual(page1.nextCursor!.txDigest, "")
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
