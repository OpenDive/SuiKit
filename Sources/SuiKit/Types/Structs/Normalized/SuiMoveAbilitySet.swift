//
//  CoinBalance.swift
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
import SwiftyJSON

/// Represents the set of abilities of a SuiMove in the ecosystem.
public struct SuiMoveAbilitySet: Equatable {
    /// Holds the abilities of the SuiMove.
    public let abilities: [String]

    /// Initializes a new instance of `SuiMoveAbilitySet` with the provided abilities.
    /// - Parameter abilities: An array of abilities in string format.
    public init(abilities: [String]) {
        self.abilities = abilities.map { $0.capitalized }
    }

    public init(graphql: RPC_MOVE_FUNCTION_FIELDS.TypeParameter) {
        self.abilities = graphql.constraints.map { $0.value!.rawValue.capitalized }
    }

    /// Initializes a new instance of `SuiMoveAbilitySet` with the abilities extracted from the given JSON.
    /// - Parameter input: A `JSON` object containing the abilities.
    public init(input: JSON) {
        self.abilities = input["abilities"].arrayValue.map { $0.stringValue.capitalized }
    }
}
