//
//  File.swift
//  
//
//  Created by Marcus Arnett on 12/19/23.
//

import Foundation

import Foundation
import XCTest
@testable import SuiKit

final class GraphQLProviderTests: XCTestCase {
    func testThatisADummyTest() async throws {
        let provider = GraphQLSuiProvider()
        try await provider.test()
    }
}
