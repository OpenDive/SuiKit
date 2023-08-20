//
//  ObjectArg.swift
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

public enum ObjectArg: KeyProtocol {
    case immOrOwned(ImmOrOwned)
    case shared(SharedObjectArg)

    public static func fromJSON(_ input: JSON) -> ObjectArg? {
        switch input["objectType"].stringValue {
        case "immOrOwnedObject":
            return .immOrOwned(ImmOrOwned(input: input))
        case "sharedObject":
            guard let shared = SharedObjectArg(input: input) else { return nil }
            return .shared(shared)
        default:
            return nil
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .immOrOwned(let immOrOwned):
            try Serializer.u8(serializer, UInt8(0))
            try Serializer._struct(serializer, value: immOrOwned)
        case .shared(let sharedArg):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: sharedArg)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ObjectArg {
        let type = try Deserializer.u8(deserializer)

        switch type {
        case 0:
            return ObjectArg.immOrOwned(
                try Deserializer._struct(deserializer)
            )
        case 1:
            return ObjectArg.shared(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}
