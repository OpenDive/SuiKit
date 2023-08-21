//
//  SuiMoveNormalizedStruct.swift
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

public struct SuiMoveNormalizedStruct {
    public let abilities: SuiMoveAbilitySet
    public let typeParameters: [SuiMoveStructTypeParameter]
    public let fields: [SuiMoveNormalizedField]

    public init(
        abilities: SuiMoveAbilitySet,
        typeParameters: [SuiMoveStructTypeParameter],
        fields: [SuiMoveNormalizedField]
    ) {
        self.abilities = abilities
        self.typeParameters = typeParameters
        self.fields = fields
    }

    public init?(input: JSON) {
        let typeParameters = input["typeParameters"].arrayValue
        let fields = input["fields"].arrayValue

        self.abilities = SuiMoveAbilitySet(input: input["abilities"])

        self.typeParameters = typeParameters.map {
            SuiMoveStructTypeParameter(
                constraints: SuiMoveAbilitySet(
                    abilities: $0["isPhantom"]["abilities"].arrayValue.map { $0.stringValue }
                ),
                isPhantom: $0["isPhantom"].boolValue
            )
        }

        var fieldsOutput: [SuiMoveNormalizedField] = []

        for field in fields {
            guard let type = SuiMoveNormalizedType.parseJSON(field["type"]) else { return nil }
            fieldsOutput.append(SuiMoveNormalizedField(
                name: field["name"].stringValue,
                type: type
            ))
        }

        self.fields = fieldsOutput
    }
}
