//
//  CheckpointTest.swift
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

final class CheckpointTest: XCTestCase {
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

    func testThatTheLatestCheckpointUpdateIsFetched() async throws {
        let toolBox = try self.fetchToolBox()
        let checkpointSequenceNumber = try await toolBox.client.getLatestCheckpointSequenceNumber()
        XCTAssertGreaterThan(Int(checkpointSequenceNumber) ?? -1, -1)
    }

    func testThatCheckpointCanBeReceivedById() async throws {
        let toolBox = try self.fetchToolBox()
        let resp = try await toolBox.client.getCheckpoint(id: "0")
        XCTAssertGreaterThan(resp.digest.count, 0)
        XCTAssertGreaterThan(resp.transactions.count, 0)
        XCTAssertNotNil(resp.epoch)
        XCTAssertNotNil(resp.sequenceNumber)
        XCTAssertNotNil(resp.networkTotalTransactions)
        XCTAssertNotNil(resp.epochRollingGasCostSummary)
        XCTAssertNotNil(resp.timestampMs)
    }

    func testThatCheckpointContentsAreReceivedByDigest() async throws {
        let toolBox = try self.fetchToolBox()
        let checkpointResp = try await toolBox.client.getCheckpoint(id: "0")
        let digest = checkpointResp.digest
        let resp = try await toolBox.client.getCheckpoint(id: digest)
        XCTAssertEqual(resp, checkpointResp)
    }

    func testThatBulkGetCheckpointsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let checkpoints = try await toolBox.client.getCheckpoints(cursor: nil, limit: 1, order: .ascending)

        XCTAssertEqual(checkpoints.nextCursor, "0")
        XCTAssertEqual(checkpoints.data.count, 1)
        XCTAssertTrue(checkpoints.hasNextPage!)

        let checkpoints1 = try await toolBox.client.getCheckpoints(cursor: checkpoints.nextCursor, limit: 1, order: .ascending)

        XCTAssertEqual(checkpoints1.nextCursor, "1")
        XCTAssertEqual(checkpoints1.data.count, 1)
        XCTAssertTrue(checkpoints1.hasNextPage!)
    }
}
