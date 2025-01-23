//
//  NormalizedModuleTest.swift
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
        let modules = try await toolBox.client.getNormalizedMoveModulesByPackage(package: self.defaultPackage)
        XCTAssertTrue(modules.keys.contains(self.defaultModule))
    }

    func testThatGettingNormalizedModuleModulesWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        guard let normalized = try await toolBox.client.getNormalizedMoveModule(
            package: self.defaultPackage,
            module: self.defaultModule
        ) else {
            XCTFail("Failed to unwrap normalized module")
            return
        }
        XCTAssertTrue(normalized.exposedFunctions.keys.contains(self.defaultFunction))
    }

    func testThatGettingNormalizedMoveFunctionsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        guard let normalized = try await toolBox.client.getNormalizedMoveFunction(
            package: self.defaultPackage,
            moduleName: self.defaultModule,
            functionName: self.defaultFunction
        ) else {
            XCTFail("Failed to unwrap normalized module")
            return
        }
        XCTAssertFalse(normalized.isEntry)
    }

    func testThatGettingNormalizedMoveStructsWorksAsIntended() async throws {
        let toolBox = try self.fetchToolBox()
        guard let structure = try await toolBox.client.getNormalizedMoveStruct(
            package: self.defaultPackage,
            module: self.defaultModule,
            structure: self.defaultStruct
        )  else {
            XCTFail("Failed to unwrap structure")
            return
        }
        XCTAssertGreaterThan(structure.fields.count, 1)
    }
}
