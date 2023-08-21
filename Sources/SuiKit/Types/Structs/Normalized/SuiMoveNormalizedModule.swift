//
//  SuiMoveNormalizedModule.swift
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

public struct SuiMoveNormalizedModule {
    public let fileFormatVersion: Int
    public let address: String
    public let name: String
    public let friends: [SuiMoveModuleId]
    public let structs: [String: SuiMoveNormalizedStruct]
    public let exposedFunctions: [String: SuiMoveNormalizedFunction]

    public init?(input: JSON) {
        var structs: [String: SuiMoveNormalizedStruct] = [:]
        var exposedFunctions: [String: SuiMoveNormalizedFunction] = [:]

        for (structKey, structValue) in input["structs"].dictionaryValue {
            structs[structKey] = SuiMoveNormalizedStruct(input: structValue)
        }

        for (exposedKey, exposedValue) in input["exposedFunctions"].dictionaryValue {
            exposedFunctions[exposedKey] = SuiMoveNormalizedFunction(input: exposedValue)
        }

        self.fileFormatVersion = input["fileFormatVersion"].intValue
        self.address = input["address"].stringValue
        self.name = input["name"].stringValue
        self.friends = input["friends"].arrayValue.map {
            SuiMoveModuleId(
                address: $0["address"].stringValue,
                name: $0["name"].stringValue
            )
        }
        self.structs = structs
        self.exposedFunctions = exposedFunctions
    }
}
