//
//  zkLoginSignatureInputsProofPoints.swift
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

public struct zkLoginSignatureInputsProofPoints: KeyProtocol, Equatable, Codable {
    public var a: [String]
    public var b: [[String]]
    public var c: [String]

    public init(
        a: [String],
        b: [[String]],
        c: [String],
    ) {
        self.a = a
        self.b = b
        self.c = c
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.sequence(self.a, Serializer.str)
        try serializer.uleb128(UInt(self.b.count))
        for val in self.b { try serializer.sequence(val, Serializer.str) }
        try serializer.sequence(self.c, Serializer.str)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> zkLoginSignatureInputsProofPoints {
        let a = try deserializer.sequence(valueDecoder: Deserializer.string)
        let count = try deserializer.uleb128()
        var b: [[String]] = []
        for _ in 0..<Int(count) { b.append(try deserializer.sequence(valueDecoder: Deserializer.string)) }
        let c = try deserializer.sequence(valueDecoder: Deserializer.string)
        return zkLoginSignatureInputsProofPoints(
            a: a,
            b: b,
            c: c
        )
    }
}
