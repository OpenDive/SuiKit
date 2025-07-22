//
//  zkLoginSignatureInputs.swift
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

/// Represents the inputs for a zkLogin signature
public struct zkLoginInputs: KeyProtocol, Equatable, Codable {
    public var proofPoints: zkLoginSignatureInputsProofPoints
    public var issBase64Details: zkLoginSignatureInputsClaim
    public var headerBase64: String

    public init(
        proofPoints: zkLoginSignatureInputsProofPoints,
        issBase64Details: zkLoginSignatureInputsClaim,
        headerBase64: String
    ) {
        self.proofPoints = proofPoints
        self.issBase64Details = issBase64Details
        self.headerBase64 = headerBase64
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.proofPoints)
        try Serializer._struct(serializer, value: self.issBase64Details)
        try Serializer.str(serializer, self.headerBase64)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> zkLoginInputs {
        return zkLoginInputs(
            proofPoints: try zkLoginSignatureInputsProofPoints.deserialize(from: deserializer),
            issBase64Details: try zkLoginSignatureInputsClaim.deserialize(from: deserializer),
            headerBase64: try Deserializer.string(deserializer)
        )
    }
}
