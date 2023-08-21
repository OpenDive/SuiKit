//
//  Signature.swift
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
import secp256k1
import Web3Core

/// The Crypto Signature
public struct Signature: Equatable, KeyProtocol {
    /// The length of the key in bytes
    public let LENGTH: Int
    
    /// The signature itself
    var signature: Data
    
    var publicKey: Data
    
    var signatureScheme: SignatureScheme
    
    init(signature: Data, publickey: Data, signatureScheme: SignatureScheme = .ED25519) {
        self.signature = signature
        self.publicKey = publickey
        self.signatureScheme = signatureScheme
        
        switch signatureScheme {
        case .ED25519:
            self.LENGTH = 64
        case .SECP256K1:
            self.LENGTH = 65
        }
    }
    
    public static func == (lhs: Signature, rhs: Signature) -> Bool {
        return lhs.signature == rhs.signature
    }
    
    public func hex() throws -> String {
        return try self.data().hexEncodedString()
    }

    public func data() throws -> Data {
        switch self.signatureScheme {
        case .ED25519:
            return self.signature
        case .SECP256K1:
            return self.signature
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Signature {
        let signatureBytes = try Deserializer.toBytes(deserializer)
        if signatureBytes.count != 64 || signatureBytes.count != 65 {
            throw AccountError.lengthMismatch
        }
        guard let stringSignature = String(data: signatureBytes, encoding: .utf8) else {
            throw AccountError.failedData
        }
        guard let bytes = Data.fromBase64(stringSignature) else { throw AccountError.invalidData }
        let signatureScheme = SignatureSchemeFlags.SIGNATURE_FLAG_TO_SCHEME[bytes[0]]
        
        if signatureScheme == "ED25519" {
            let signature = Array(bytes[1...(bytes.count - ED25519PublicKey.LENGTH)])
            let pubKeyBytes = Array(bytes[(1 + signature.count)...])
            let pubKey = try ED25519PublicKey(data: Data(pubKeyBytes))
            return Signature(signature: Data(signature), publickey: pubKey.key)
        } else if signatureScheme == "SECP256K1" {
            let signature = Array(bytes[1...(bytes.count - SECP256K1PublicKey.LENGTH)])
            let pubKeyBytes = Array(bytes[(1 + signature.count)...])
            let pubKey = try SECP256K1PublicKey(data: Data(pubKeyBytes))
            return Signature(signature: Data(signature), publickey: pubKey.key, signatureScheme: .SECP256K1)
        } else {
            throw AccountError.cannotBeDeserialized
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        var serializedSignature = Data(capacity: 1 + signature.count + publicKey.count)
        guard let signatureFlag = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG[signatureScheme.rawValue] else {
            throw AccountError.cannotBeSerialized
        }
        serializedSignature.append(signatureFlag)
        serializedSignature.append(contentsOf: self.signature)
        serializedSignature.append(contentsOf: self.publicKey)
        try Serializer.str(serializer, serializedSignature.base64EncodedString())
    }
}

public struct SignatureSchemeFlags {
    public static var SIGNATURE_SCHEME_TO_FLAG: [String: UInt8] = [
        "ED25519": 0x00,
        "SECP256K1": 0x01
    ]
    
    public static var SIGNATURE_FLAG_TO_SCHEME: [UInt8: String] = [
        0x00: "ED25519",
        0x01: "SECP256K1"
    ]
}
