//
//  Signature.swift
//  AptosKit
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

/// The ED25519 Signature
public struct Signature: Equatable, KeyProtocol, CustomStringConvertible {
    /// The length of the key in bytes
    static let LENGTH: Int = 64

    /// The signature itself
    var signature: Data

    init(signature: Data) {
        self.signature = signature
    }

    public static func == (lhs: Signature, rhs: Signature) -> Bool {
        return lhs.signature == rhs.signature
    }

    public var description: String {
        return "0x\(signature.hexEncodedString())"
    }

    func data() -> Data {
        return self.signature
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Signature {
        let signatureBytes = try Deserializer.toBytes(deserializer)
        if signatureBytes.count != LENGTH {
            throw SuiError.lengthMismatch
        }
        return Signature(signature: signatureBytes)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.signature)
    }
}
