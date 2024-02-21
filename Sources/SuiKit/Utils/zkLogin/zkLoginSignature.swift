//
//  zkLoginSignature.swift
//  SuiKit
//
//  Copyright (c) 2024 OpenDive
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

public struct zkLoginSignature: KeyProtocol, Equatable {
    public var inputs: zkLoginSignatureInputs
    public var maxEpoch: UInt64
    public var userSignature: [UInt8]

    public init(inputs: zkLoginSignatureInputs, maxEpoch: UInt64, userSignature: [UInt8]) {
        self.inputs = inputs
        self.maxEpoch = maxEpoch
        self.userSignature = userSignature
    }

    public init(serializedData: Data) throws {
        let der = Deserializer(data: serializedData)
        let result = try zkLoginSignature.deserialize(from: der)
        self.init(inputs: result.inputs, maxEpoch: result.maxEpoch, userSignature: result.userSignature)
    }

    public func getSignatureBytes(signature: String? = nil) throws -> Data {
        let ser = Serializer()
        guard let bytes = signature != nil ? Data(base64Encoded: signature!) : Data(self.userSignature) else { throw SuiError.notImplemented }
        try Serializer._struct(ser, value: zkLoginSignature(inputs: self.inputs, maxEpoch: self.maxEpoch, userSignature: [UInt8](bytes)))
        return ser.output()
    }

    public func getSignature() throws -> String {
        let bytes = try self.getSignatureBytes()
        var signatureBytes = Data(count: bytes.count)
        signatureBytes[0] = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["ZkLogin"]!
        signatureBytes[1..<bytes.count] = bytes
        return signatureBytes.base64EncodedString()
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.inputs)
        try Serializer.u64(serializer, self.maxEpoch)
        try serializer.sequence(self.userSignature, Serializer.u8)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> zkLoginSignature {
        return zkLoginSignature(
            inputs: try Deserializer._struct(deserializer),
            maxEpoch: try Deserializer.u64(deserializer),
            userSignature: [UInt8](try Deserializer.toBytes(deserializer))
        )
    }
}
