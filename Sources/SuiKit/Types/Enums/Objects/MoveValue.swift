//
//  MoveValue.swift
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

public enum MoveValue {
    case number(Int)
    case boolean(Bool)
    case string(String)
    case moveValues([MoveValue])
    case id(MoveValueId)
    case moveStruct(MoveStruct)
    case null

    public static func parseJSON(_ input: JSON) -> MoveValue {
        if let number = input.int {
            return .number(number)
        }

        if let bool = input.bool {
            return .boolean(bool)
        }

        if let string = input.string {
            return .string(string)
        }

        if let array = input.array {
            return .moveValues(array.map { MoveValue.parseJSON($0) })
        }

        if input["id"].exists() {
            return .id(MoveValueId(input: input))
        }

        if let structure = MoveStruct.parseJSON(input) {
            return .moveStruct(structure)
        }

        return .null
    }
}
