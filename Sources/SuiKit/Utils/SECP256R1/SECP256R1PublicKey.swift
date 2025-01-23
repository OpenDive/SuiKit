//
//  SECP256R1PublicKey.swift
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
import CryptoKit
import Blake2
import Security

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct SECP256R1PublicKey: PublicKeyProtocol {
    public static let LENGTH: Int = 33

    public var key: P256.Signing.PublicKey

    public typealias DataValue = P256.Signing.PublicKey

    public init(key: P256.Signing.PublicKey) {
        self.key = key
    }

    public init(data: Data) throws {
        if let key = try? P256.Signing.PublicKey(compressedRepresentation: data) {
            self.key = key
        } else {
            throw AccountError.invalidData
        }
    }

    public init(value: String) throws {
        guard let data = Data.fromBase64(value) else { throw AccountError.invalidData }
        try self.init(data: data)
    }

    public init(hexString: String) throws {
        guard let data = hexString.data(using: .utf8) else { throw AccountError.invalidData }
        try self.init(data: data)
    }

    public var description: String {
        return self.hex()
    }

    public func verify(data: Data, signature: Signature) throws -> Bool {
        return self.key.isValidSignature(
            try P256.Signing.ECDSASignature(
                rawRepresentation: signature.signature
            ),
            for: data
        )
    }

    public func base64() -> String {
        return self.key.compressedRepresentation.base64EncodedString()
    }

    public func hex() -> String {
        return "0x\(self.key.compressedRepresentation.hexEncodedString())"
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
        let rawBytes = self.key.compressedRepresentation
        var suiBytes = Data(count: rawBytes.count + 1)
        try suiBytes.set([SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["SECP256R1"]!])
        try suiBytes.set([UInt8](rawBytes), offset: 1)

        return [UInt8](suiBytes)
    }

    public func toSerializedSignature(signature: Signature) throws -> String {
        let rawBytes = self.key.compressedRepresentation
        var serializedSignature = Data(count: signature.signature.count + rawBytes.count)
        serializedSignature[0] = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["SECP256R1"]!
        serializedSignature[1..<signature.signature.count] = signature.signature
        serializedSignature[1+signature.signature.count..<1+signature.signature.count+rawBytes.count] = rawBytes

        return serializedSignature.base64EncodedString()
    }

    public func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool {
        return try self.verifyWithIntent(transactionBlock, signature, .TransactionData)
    }

    public func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool {
        let intentMessage = RawSigner.messageWithIntent(intent, Data(bytes))
        let digest = try Blake2b.hash(size: 32, data: intentMessage)

        return try self.verify(data: digest, signature: signature)
    }

    public func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool {
        let ser = Serializer()
        try ser.sequence(message, Serializer.u8)
        return try self.verifyWithIntent([UInt8](ser.output()), signature, .PersonalMessage)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256R1PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256R1PublicKey.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try SECP256R1PublicKey(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key.compressedRepresentation)
    }
}
