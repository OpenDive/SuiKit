//
//  SuiMoveNormalizedFunction.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

public struct SuiMoveNormalizedFunction {
    public let visibility: SuiMoveVisibility
    public let isEntry: Bool
    public let typeParameters: [SuiMoveAbilitySet]
    public let parameters: [SuiMoveNormalizedType]
    public let returnValues: [SuiMoveNormalizedType]

    public init(
        visibility: SuiMoveVisibility,
        isEntry: Bool,
        typeParameters: [SuiMoveAbilitySet],
        parameters: [SuiMoveNormalizedType],
        returnValues: [SuiMoveNormalizedType]
    ) {
        self.visibility = visibility
        self.isEntry = isEntry
        self.typeParameters = typeParameters
        self.parameters = parameters
        self.returnValues = returnValues
    }

    public init?(input: JSON) {
        guard let visibility = SuiMoveVisibility.parseJSON(input["visibility"]) else { return nil }
        self.visibility = visibility
        self.isEntry = input["isEntry"].boolValue
        self.typeParameters = input["typeParameters"].arrayValue.map { SuiMoveAbilitySet(input: $0) }
        self.parameters = input["parameters"].arrayValue.compactMap { SuiMoveNormalizedType.parseJSON($0) }
        self.returnValues = input["returnValues"].arrayValue.compactMap { SuiMoveNormalizedType.parseJSON($0) }
    }

    public func hasTxContext() throws -> Bool {
        guard !(parameters.isEmpty) else { return false }

        let possiblyTxContext = parameters.last!

        guard let structTag = possiblyTxContext.extractStructTag() else { return false }

        return
            try structTag.address.hex() == Inputs.normalizeSuiAddress(value: "0x2") &&
            structTag.module == "tx_context" &&
            structTag.name == "TxContext"
    }
}
