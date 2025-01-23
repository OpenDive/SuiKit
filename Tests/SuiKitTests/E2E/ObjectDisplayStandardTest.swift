//
//  ObjectDisplayStandardTest.swift
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

final class ObjectDisplayStandardTest: XCTestCase {
    var toolBox: TestToolbox?
    var packageId: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.packageId = try await self.fetchToolBox().publishPackage("display-test").packageId
    }

    private func fetchToolBox() throws -> TestToolbox {
        guard let toolBox = self.toolBox else {
            XCTFail("Failed to get Toolbox")
            throw NSError(domain: "Failed to get Toolbox", code: -1)
        }
        return toolBox
    }

    private func fetchPackageId() throws -> String {
        guard let packageId = self.packageId else {
            XCTFail("Failed to get Package ID")
            throw NSError(domain: "Failed to get Package ID", code: -1)
        }
        return packageId
    }

    func testThatGettingDisplayFieldsCanReceiveErrorObjects() async throws {
        let toolBox = try self.fetchToolBox()
        let resp = try await toolBox.client.getOwnedObjects(
            owner: try toolBox.address(),
            filter: SuiObjectDataFilter.structType("\(try self.fetchPackageId())::boars::Boar"),
            options: SuiObjectDataOptions(showDisplay: true, showType: true)
        ).data
        guard let data = resp[0].data else {
            XCTFail("Failed to get data from Response")
            return
        }
        let boarId = data.objectId
        let displayFull = (try await toolBox.client.getObject(objectId: boarId, options: SuiObjectDataOptions(showDisplay: true)))!.data!.display!
        let display = displayFull.data!

        XCTAssertEqual("10", display["age"])
        XCTAssertEqual(try toolBox.address(), display["buyer"])
        XCTAssertEqual("Chris", display["creator"])
        XCTAssertEqual("Unique Boar from the Boars collection with First Boar and \(boarId)", display["description"])
        XCTAssertEqual("https://get-a-boar.com/first.png", display["img_url"])
        XCTAssertEqual("First Boar", display["name"])
        XCTAssertEqual("", display["price"])
        XCTAssertEqual("https://get-a-boar.com/", display["project_url"])
        XCTAssertEqual("https://get-a-boar.fullurl.com/", display["full_url"])
        XCTAssertEqual("{name}", display["escape_syntax"])

        let error = "Field value idd cannot be found in struct; Field value namee cannot be found in struct"

        XCTAssertEqual(displayFull.error, .displayError(error: error))
    }

    func testThatGettingDisplayFieldsForObjectThatHasNoDisplayObjectWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let coin = try await toolBox.getCoins().data[0]
        let coinId = coin.coinObjectId
        let display = (try await toolBox.client.getObject(objectId: coinId, options: SuiObjectDataOptions(showDisplay: true)))
        XCTAssertEqual(display?.data?.display?.data, [:])
    }
}
