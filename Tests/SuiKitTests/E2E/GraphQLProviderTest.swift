//
//  File.swift
//  
//
//  Created by Marcus Arnett on 1/11/24.
//

import Foundation
import XCTest
import SwiftyJSON
@testable import SuiKit

final class GraphQLProviderTest: XCTestCase {
    var toolBox: TestToolbox?

    let defaultPackage = "0x2"
    let defaultModule = "coin"
    let defaultFunction = "balance"
    let defaultStruct = "Coin"

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

    func testThatGettingArgTypesFromMoveFunctionWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let provider = GraphQLSuiProvider()
        let argTypes = try await provider.getNormalizedMoveModule(package: self.defaultPackage, module: self.defaultModule)
    }
}
