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
    
    func testThatGettingArgTypesFromMoveFunctionWorksAsIntended() async throws {
        let provider = GraphQLSuiProvider(connection: LocalnetConnection())
        let argTypes = try await provider.getMoveFunctionArgTypes(
            package: "0x0000000000000000000000000000000000000000000000000000000000000002",
            module: "balance",
            function: "increase_supply"
        )
        print(argTypes)
    }
}
