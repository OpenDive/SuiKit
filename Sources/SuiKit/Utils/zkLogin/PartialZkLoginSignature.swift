//
//  PartialzkLoginSignature.swift
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

public struct PartialzkLoginSignature: KeyProtocol, Equatable, Codable {
    public var proofPoints: zkLoginSignatureInputsProofPoints
    public var issBase64Details: zkLoginSignatureInputsClaim
    public var headerBase64: String

    public init(proofPoints: zkLoginSignatureInputsProofPoints, issBase64Details: zkLoginSignatureInputsClaim, headerBase64: String) {
        self.proofPoints = proofPoints
        self.issBase64Details = issBase64Details
        self.headerBase64 = headerBase64
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.proofPoints)
        try Serializer._struct(serializer, value: self.issBase64Details)
        try Serializer.str(serializer, self.headerBase64)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> PartialzkLoginSignature {
        return PartialzkLoginSignature(
            proofPoints: try zkLoginSignatureInputsProofPoints.deserialize(from: deserializer),
            issBase64Details: try zkLoginSignatureInputsClaim.deserialize(from: deserializer),
            headerBase64: try Deserializer.string(deserializer)
        )
    }

    // MARK: - Equatable
    public static func == (lhs: PartialzkLoginSignature, rhs: PartialzkLoginSignature) -> Bool {
        return lhs.proofPoints == rhs.proofPoints &&
               lhs.issBase64Details == rhs.issBase64Details &&
               lhs.headerBase64 == rhs.headerBase64
    }

    // MARK: - Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.proofPoints = try container.decode(zkLoginSignatureInputsProofPoints.self, forKey: .proofPoints)
        self.issBase64Details = try container.decode(zkLoginSignatureInputsClaim.self, forKey: .issBase64Details)
        self.headerBase64 = try container.decode(String.self, forKey: .headerBase64)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(proofPoints, forKey: .proofPoints)
        try container.encode(issBase64Details, forKey: .issBase64Details)
        try container.encode(headerBase64, forKey: .headerBase64)
    }

    private enum CodingKeys: String, CodingKey {
        case proofPoints
        case issBase64Details
        case headerBase64
    }
}
