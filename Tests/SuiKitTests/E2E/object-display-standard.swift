//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/18/23.
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
            filter: SuiObjectDataFilter.StructType("\(try self.fetchPackageId())::boars::Boar"),
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
