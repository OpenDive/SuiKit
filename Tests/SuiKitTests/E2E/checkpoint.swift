//
//  checkpoint.swift
//  
//
//  Created by Marcus Arnett on 8/8/23.
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
        XCTAssertTrue(checkpoints.hasNextPage)

        let checkpoints1 = try await toolBox.client.getCheckpoints(cursor: checkpoints.nextCursor, limit: 1, order: .ascending)

        XCTAssertEqual(checkpoints1.nextCursor, "1")
        XCTAssertEqual(checkpoints1.data.count, 1)
        XCTAssertTrue(checkpoints1.hasNextPage)
    }
}
