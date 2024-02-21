//
//  zkLoginPublicIdentifier.swift
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
import BigInt
import Blake2

public struct zkLoginPublicIdentifier: PublicKeyProtocol {
    public var key: Data

    public typealias DataValue = Data

    public static let LENGTH: Int = 32

    public init(data: Data) throws {
        guard data.count == zkLoginPublicIdentifier.LENGTH else {
            throw AccountError.invalidPublicKey
        }
        self.key = data
    }

    public init(addressSeed: BigInt, iss: String) throws {
        let addressSeedBytesBigEndian = zkLoginUtilities.toPaddedBigEndianBytes(num: addressSeed, width: Self.LENGTH)
        let issBytes = Data(iss.utf8)
        var tmp = Data(count: (1 + issBytes.count + addressSeedBytesBigEndian.count))
        try tmp.set([UInt8(issBytes.count)], offset: 0)
        try tmp.set([UInt8](issBytes), offset: 1)
        try tmp.set(addressSeedBytesBigEndian, offset: (1 + issBytes.count))
        self.key = tmp
    }

    public func base64() -> String {
        return key.base64EncodedString()
    }

    public func hex() -> String {
        return "0x\(self.key.hexEncodedString())"
    }

    public func toSuiAddress() throws -> String {
        return try Inputs.normalizeSuiAddress(
            value: try Blake2b.hash(
                size: 32,
                data: Data(try self.toSuiBytes())
            ).hexEncodedString()[0..<(32 * 2)]
        )
    }

    /// Converts the public key to a Sui address.
    /// - Throws: If any error occurs during conversion.
    /// - Returns: A string representing the Sui address.
    public func toSuiPublicKey() throws -> String {
        let bytes = try self.toSuiBytes()
        return bytes.toBase64()
    }

    /// Converts the public key to Sui bytes.
    /// - Throws: If any error occurs during conversion.
    /// - Returns: An array of bytes representing the Sui public key.
    public func toSuiBytes() throws -> [UInt8] {
        let rawBytes = self.key
        var suiBytes = Data(count: rawBytes.count + 1)
        try suiBytes.set([SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["ZkLogin"]!])
        try suiBytes.set([UInt8](rawBytes), offset: 1)
        
        return [UInt8](suiBytes)
    }

    public func verify(data: Data, signature: Signature) throws -> Bool {
        throw SuiError.notImplemented
    }

    public func toSerializedSignature(signature: Signature) throws -> String {
        throw SuiError.notImplemented
    }

    public func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool {
        throw SuiError.notImplemented
    }

    public func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool {
        throw SuiError.notImplemented
    }

    public func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool {
        throw SuiError.notImplemented
    }

    public static func deserialize(from deserializer: Deserializer) throws -> zkLoginPublicIdentifier {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != zkLoginPublicIdentifier.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try zkLoginPublicIdentifier(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }

    public var description: String {
        self.hex()
    }
}
