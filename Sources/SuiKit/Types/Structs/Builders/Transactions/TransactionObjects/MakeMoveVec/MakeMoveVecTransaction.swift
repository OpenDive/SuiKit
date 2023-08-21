//
//  MakeMoveVecTransaction.swift
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

public struct MakeMoveVecTransaction: KeyProtocol, TransactionProtocol {
    public let objects: [TransactionArgument]
    public let type: String?

    public init(objects: [TransactionArgument], type: String?) {
        self.objects = objects
        self.type = type
    }

    public init?(input: JSON) {
        let vec = input.arrayValue
        self.objects = vec[0].arrayValue.compactMap {
            TransactionArgument.fromJSON($0)
        }
        self.type = vec[1].string
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(0)
        try serializer.sequence(objects, Serializer._struct)
        if let type { try Serializer.str(serializer, type) }
    }

    public static func deserialize(
        from deserializer: Deserializer
    ) throws -> MakeMoveVecTransaction {
        let _ = Deserializer.uleb128(deserializer)
        return MakeMoveVecTransaction(
            objects: try deserializer.sequence(valueDecoder: Deserializer._struct),
            type: try? Deserializer.string(deserializer)
        )
    }

    public func executeTransaction(
        objects: inout [ObjectsToResolve],
        inputs: inout [TransactionBlockInput]
    ) throws {
        try self.objects.forEach { argument in
            try argument.encodeInput(objects: &objects, inputs: &inputs)
        }
    }
}
