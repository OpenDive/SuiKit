//
//  PublicKey.swift
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
import ed25519swift
import Blake2

/// The ED25519 Public Key
public struct ED25519PublicKey: Equatable, PublicKeyProtocol {
    /// The length of the key in bytes
    public static let LENGTH: Int = 32

    /// The key itself
    public var key: Data

    public init(data: Data) throws {
        guard data.count == ED25519PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = data
    }
    
    public init(hexString: String) throws {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        guard Data(hex: hexValue).count == ED25519PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = Data(hex: hexValue)
    }
    
    public init(value: String) throws {
        guard let result = Data.fromBase64(value) else { throw SuiError.notImplemented }
        guard result.count == ED25519PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = result
    }

    public static func == (lhs: ED25519PublicKey, rhs: ED25519PublicKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return self.hex()
    }

    /// Verify a digital signature for a given data using Ed25519 algorithm.
    ///
    /// This function verifies a digital signature provided by the Ed25519 algorithm for a given data and public key.
    ///
    /// - Parameters:
    ///    - data: The Data object to be verified.
    ///    - signature: The Signature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    ///
    /// - Throws: An error of type Ed25519Error.invalidSignature if the signature is invalid or an error occurred during verification.
    public func verify(data: Data, signature: Signature) throws -> Bool {
        return Ed25519.verify(
            signature: [UInt8](signature.signature),
            message: [UInt8](data),
            publicKey: [UInt8](self.key)
        )
    }
    
    public func base64() -> String {
        return key.base64EncodedString()
    }
    
    public func hex() -> String {
        return "0x\(key.hexEncodedString())"
    }
    
    public func toSuiAddress() throws -> String {
        var tmp = Data(count: ED25519PublicKey.LENGTH + 1)
        try tmp.set([SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["ED25519"]!])
        try tmp.set([UInt8](self.key), offset: 1)
        let result = normalizeSuiAddress(
            value: try Blake2.hash(.b2b, size: 32, data: tmp).hexEncodedString()[0..<ED25519PublicKey.LENGTH * 2]
        )
        return result
    }
    
    public func toSuiPublicKey() throws -> String {
        let bytes = try self.toSuiBytes()
        return bytes.toBase64()
    }
    
    public func toSuiBytes() throws -> [UInt8] {
        let rawBytes = self.key
        var suiBytes = Data(count: rawBytes.count + 1)
        try suiBytes.set([SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["ED25519"]!])
        try suiBytes.set([UInt8](rawBytes), offset: 1)
        
        return [UInt8](suiBytes)
    }

    public func toSerializedSignature(signature: Signature) throws -> String {
        var serializedSignature = Data(count: signature.signature.count + self.key.count)
        serializedSignature[0] = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["ED25519"]!
        serializedSignature[1..<signature.signature.count] = signature.signature
        serializedSignature[1+signature.signature.count..<1+signature.signature.count+self.key.count] = self.key

        return serializedSignature.base64EncodedString()
    }
    
    public func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool {
        return try self.verifyWithIntent(transactionBlock, signature, .TransactionData)
    }
    
    public func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool {
        let intentMessage = messageWithIntent(intent, Data(bytes))
        let digest = try Blake2.hash(.b2b, size: 32, data: intentMessage)
        
        return try self.verify(data: digest, signature: signature)
    }
    
    public func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool {
        let ser = Serializer()
        try ser.sequence(message, Serializer.u8)
        return try self.verifyWithIntent([UInt8](ser.output()), signature, .PersonalMessage)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ED25519PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != ED25519PublicKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return try ED25519PublicKey(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }

    public func serializeModule(_ serializer: Serializer) {
        serializer.fixedBytes(self.key)
    }
}
