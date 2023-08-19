//
//  Input.swift
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

public struct Input: KeyProtocol {
    var type: InputType

    public init(type: InputType) {
        self.type = type
    }

    public init?(input: JSON) {
        switch input["type"].stringValue {
        case "object":
            guard let object = ObjectArg.fromJSON(input) else { return nil }
            self.type = .object(object)
        case "pure":
            guard let pure = PureCallArg(input: input) else { return nil }
            self.type = .pure(pure)
        default:
            return nil
        }
    }

    public var kind: String {
        switch type {
        case .pure:
            return "pure"
        case .object:
            return "object"
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.type)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Input {
        return Input(type: try Deserializer._struct(deserializer))
    }
}

public extension Input {
    func isMutableSharedObjectInput() -> Bool {
        return self.getSharedObjectInput()?.mutable ?? false
    }

    func getSharedObjectInput() -> SharedObjectArg? {
        switch self.type {
        case .object(let object):
            switch object {
            case .shared(let sharedArg):
                return sharedArg
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
