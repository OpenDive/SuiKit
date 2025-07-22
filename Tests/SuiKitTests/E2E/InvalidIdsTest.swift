//
//  InvalidIdsTest.swift
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

final class InvalidIdsTest: XCTestCase {
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

    func testThatVerifiesGetOwnedObjectsThrowsWithAnInvalidSuiAddress() async throws {
        do {
            let toolBox = try self.fetchToolBox()
            _ = try await toolBox.client.getOwnedObjects(owner: "")
            XCTFail("Function did not throw")
        } catch {
            XCTAssertEqual(0, 0)
        }
    }

    func testThatVariousFunctionsWillThrowWithVariousWrongAddresses() async throws {
        // Empty ID
        do {
            let toolBox = try self.fetchToolBox()
            _ = try await toolBox.client.getObject(objectId: "")
            XCTFail("Function did not throw")
        } catch {
            XCTAssertEqual(0, 0)
        }

        // More than 20 Bytes
        do {
            let toolBox = try self.fetchToolBox()
            _ = try await toolBox.client.getDynamicFields(parentId: "0x0000000000000000000000004ce52ee7b659b610d59a1ced129291b3d0d4216322")
            XCTFail("Function did not throw")
        } catch {
            XCTAssertEqual(0, 0)
        }

        // Wrong Batch Request (0xWRONG)
        do {
            let toolBox = try self.fetchToolBox()
            let objectIds = ["0xBABE", "0xCAFE", "0xWRONG", "0xFACE"]
            _ = try await toolBox.client.getMultiObjects(ids: objectIds)
            XCTFail("Function did not throw")
        } catch {
            XCTAssertEqual(0, 0)
        }
    }

    func testThatInvalidDigestsForClientFunctionsThrowWithInvalidDigests() async throws {
        // Empty Digest
        do {
            let toolBox = try self.fetchToolBox()
            _ = try await toolBox.client.getTransactionBlock(digest: "")
            XCTFail("Function did not throw")
        } catch {
            XCTAssertEqual(0, 0)
        }

        // Wrong Batch Request
        do {
            let toolBox = try self.fetchToolBox()
            let digests = ["AQ7FA8JTGs368CvMkXj2iFz2WUWwzP6AAWgsLpPLxUmr", "wrong"]
            _ = try await toolBox.client.multiGetTransactionBlocks(digests: digests)
            XCTFail("Function did not throw")
        } catch {
            XCTAssertEqual(0, 0)
        }
    }
}
