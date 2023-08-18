//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/18/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class NormalizedModuleTest: XCTestCase {
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
        let argTypes = try await toolBox.client.getMoveFunctionArgTypes(
            package: self.defaultPackage,
            module: self.defaultModule,
            function: self.defaultFunction
        )
        XCTAssertEqual(argTypes, [.object(.byImmutableReference)])
    }

    func testThatGettingNormalizedModulesByPackageWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let modules = try await toolBox.client.getNormalizedMoveModulesByPackage(self.defaultPackage)
        XCTAssertTrue(modules.keys.contains(self.defaultModule))
    }

    func testThatGettingNormalizedModuleModulesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let normalized = try await toolBox.client.getNormalizedModuleModule(
            package: self.defaultPackage,
            module: self.defaultModule
        )
        XCTAssertTrue(normalized.exposedFunctions.keys.contains(self.defaultFunction))
    }

    func testThatGettingNormalizedMoveFunctionsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let normalized = try await toolBox.client.getNormalizedMoveFunction(
            self.defaultPackage,
            self.defaultModule,
            self.defaultFunction
        )
        XCTAssertFalse(normalized.isEntry)
    }

    func testThatGettingNormalizedMoveStructsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        let structure = try await toolBox.client.getNormalizedMoveStruct(
            package: self.defaultPackage,
            module: self.defaultModule,
            structure: self.defaultStruct
        )
        XCTAssertGreaterThan(structure.fields.count, 1)
    }
}
