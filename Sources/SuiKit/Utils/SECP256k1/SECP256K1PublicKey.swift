//
//  SECP256K1PublicKey.swift
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
import secp256k1
import Blake2

public struct SECP256K1PublicKey: Equatable, PublicKeyProtocol {
    /// The length of the key in bytes
    public static let LENGTH: Int = 33

    public var key: Data

    public init(data: Data) throws {
        guard data.count == SECP256K1PublicKey.LENGTH else {
            throw AccountError.invalidPublicKey
        }
        self.key = data
    }

    public init(hexString: String) throws {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        guard Data(hex: hexValue).count == SECP256K1PublicKey.LENGTH else {
            throw AccountError.invalidPublicKey
        }
        self.key = Data(hex: hexValue)
    }

    public init(value: String) throws {
        guard let result = Data.fromBase64(value) else { throw AccountError.invalidData }
        guard result.count == SECP256K1PublicKey.LENGTH else {
            throw AccountError.invalidPublicKey
        }
        self.key = result
    }

    public static func == (lhs: SECP256K1PublicKey, rhs: SECP256K1PublicKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return "0x\(key.hexEncodedString())"
    }

    public func verify(data: Data, signature: Signature) throws -> Bool {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)) else { throw AccountError.invalidContext }
        let hashedData = data.sha256()
        var signatureEcdsa: secp256k1_ecdsa_signature = secp256k1_ecdsa_signature()
        let serializedSignature = Data(signature.signature[0..<64])
        let resultSignature = serializedSignature.withUnsafeBytes { (rawSignaturePtr: UnsafeRawBufferPointer) -> Int32? in
            if let rawPtr = rawSignaturePtr.baseAddress, rawSignaturePtr.count > 0 {
                let ptr = rawPtr.assumingMemoryBound(to: UInt8.self)
                return withUnsafeMutablePointer(to: &signatureEcdsa) { (mutablePtrEcdsa: UnsafeMutablePointer<secp256k1_ecdsa_signature>) -> Int32? in
                    let res = secp256k1_ecdsa_signature_parse_compact(ctx, mutablePtrEcdsa, ptr)
                    return res
                }
            } else {
                return nil
            }
        }
        guard let _ = resultSignature, resultSignature != 0 else { throw AccountError.invalidParsedSignature }
        var pubKeyObject: secp256k1_pubkey = secp256k1_pubkey()
        let pubKeyResult = self.key.withUnsafeBytes { (rawUnsafePubkeyPtr: UnsafeRawBufferPointer) -> Int32? in
            if let rawPubKey = rawUnsafePubkeyPtr.baseAddress, rawUnsafePubkeyPtr.count > 0 {
                let pubKeyPtr = rawPubKey.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_parse(ctx, &pubKeyObject, pubKeyPtr, self.key.count)
                return res
            } else {
                return nil
            }
        }
        guard let _ = pubKeyResult, pubKeyResult != 0 else { throw AccountError.invalidParsedPublicKey }
        return withUnsafePointer(to: signatureEcdsa) { (signaturePtr: UnsafePointer<secp256k1_ecdsa_signature>) -> Bool in
            return hashedData.withUnsafeBytes { (rawUnsafeDataPtr: UnsafeRawBufferPointer) -> Bool in
                if let dataRawPtr = rawUnsafeDataPtr.baseAddress, rawUnsafeDataPtr.count > 0 {
                    let dataPtr = dataRawPtr.assumingMemoryBound(to: UInt8.self)
                    return withUnsafePointer(to: pubKeyObject) { (pubKeyPtr: UnsafePointer<secp256k1_pubkey>) -> Bool in
                        return secp256k1.secp256k1_ecdsa_verify(ctx, signaturePtr, dataPtr, pubKeyPtr) != 0
                    }
                } else {
                    return false
                }
            }
        }
    }

    public func base64() -> String {
        return key.base64EncodedString()
    }

    public func hex() -> String {
        return "0x\(key.hexEncodedString())"
    }

    public func toSuiAddress() throws -> String {
        return try Inputs.normalizeSuiAddress(
            value: try Blake2b.hash(
                size: 32,
                data: Data(try self.toSuiBytes())
            ).hexEncodedString()[0..<(32 * 2)]
        )
    }

    public func toSuiPublicKey() throws -> String {
        let bytes = try self.toSuiBytes()
        return bytes.toBase64()
    }

    public func toSuiBytes() throws -> [UInt8] {
        let rawBytes = self.key
        var suiBytes = Data(count: rawBytes.count + 1)
        try suiBytes.set([SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["SECP256K1"]!])
        try suiBytes.set([UInt8](rawBytes), offset: 1)
        
        return [UInt8](suiBytes)
    }

    public func toSerializedSignature(signature: Signature) throws -> String {
        var serializedSignature = Data(count: signature.signature.count + self.key.count)
        serializedSignature[0] = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["SECP256K1"]!
        serializedSignature[1..<signature.signature.count] = signature.signature
        serializedSignature[1+signature.signature.count..<1+signature.signature.count+self.key.count] = self.key
        
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

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PublicKey.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try SECP256K1PublicKey(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
