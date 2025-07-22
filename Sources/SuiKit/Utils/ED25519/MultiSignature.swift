//
//  MultiSignature.swift
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

/// The ED25519 Multi-Signature
public struct MultiSignature: EncodingProtocol, Equatable {
    /// The signatures themselves
    public var signatures: [Signature]

    /// The compact representation of which keys among a set of N possible keys have signed a given message
    public var bitmap: Data

    init(publicKey: MultiPublicKey, signatureMap: [(ED25519PublicKey, Signature)]) {
        self.signatures = []
        var bitmap: UInt32 = 0

        for entry in signatureMap {
            self.signatures.append(entry.1)
            if let index = publicKey.keys.firstIndex(of: entry.0) {
                let shift = 31 - index
                bitmap = bitmap | (1 << shift)
            }
        }

        self.bitmap = withUnsafeBytes(of: (bitmap.bigEndian, UInt32.self)) { Data($0) }.prefix(4)
    }

    /// Serialize the concatenated signatures and bitmap of an ED25519 Multi-signature instance to a Data object.
    ///
    /// This function concatenates the signatures of the instance and serializes the concatenated signatures and bitmap to a Data object.
    ///
    /// - Returns: A Data object containing the serialized concatenated signatures and bitmap.
    public func toBytes() throws -> Data {
        var concatenatedSignatures: Data = Data()
        for signature in self.signatures {
            concatenatedSignatures += try signature.data()
        }
        return concatenatedSignatures + self.bitmap
    }

    /// Serializes an output instance using the given Serializer.
    ///
    /// - Parameter serializer: The Serializer instance used to serialize the data.
    ///
    /// - Throws: An error if the serialization fails.
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.toBytes())
    }
}
