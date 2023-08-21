//
//  InputType.swift
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

public indirect enum InputType: KeyProtocol {
    case pure(PureCallArg)
    case object(ObjectArg)

    public static func fromJSON(_ input: JSON) -> InputType? {
        switch input["type"].stringValue {
        case "pure":
            guard let pure = PureCallArg(input: input) else { return nil }
            return .pure(pure)
        case "object":
            guard let object = ObjectArg.fromJSON(input) else { return nil }
            return .object(object)
        default:
            return nil
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .pure(let pure):
            try serializer.uleb128(UInt(0))
            try Serializer._struct(serializer, value: pure)
        case .object(let object):
            try serializer.uleb128(UInt(1))
            try Serializer._struct(serializer, value: object)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> InputType {
        let value = try Deserializer.u8(deserializer)
        switch value {
        case 0:
            return .pure(try Deserializer._struct(deserializer))
        case 1:
            return .object(try Deserializer._struct(deserializer))
        default:
            throw SuiError.unableToDeserialize
        }
    }
}
