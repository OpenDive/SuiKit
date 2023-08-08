//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation
import secp256k1
import Blake2

public struct SECP256K1PublicKey: Equatable, PublicKeyProtocol {
    /// The length of the key in bytes
    public static let LENGTH: Int = 33

    /// The key itself
    public var key: Data

    public init(data: Data) throws {
        guard data.count == SECP256K1PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = data
    }
    
    public init(hexString: String) throws {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        guard Data(hex: hexValue).count == SECP256K1PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = Data(hex: hexValue)
    }

    public init(value: String) throws {
        guard let result = Data.fromBase64(value) else { throw SuiError.notImplemented }
        guard result.count == SECP256K1PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = result
    }

    public static func == (lhs: SECP256K1PublicKey, rhs: SECP256K1PublicKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return "0x\(key.hexEncodedString())"
    }

    /// Verify a digital signature for a given data using Ed25519 algorithm.
    ///
    /// This function verifies a digital signature provided by the Ed25519 algorithm for a given data and public key.
    ///
    /// - Parameters:
    ///    - data: The Data object to be verified.
    ///    - signature: The Signature object containing the signature to be verified.
    ///    - privateKey: The private key data used for generating the signature.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    ///
    /// - Throws: An error of type Ed25519Error.invalidSignature if the signature is invalid or an error occurred during verification.
    public func verify(data: Data, signature: Signature) throws -> Bool {
        let verifyKey = try secp256k1.Signing.PublicKey(
            dataRepresentation: self.key,
            format: .compressed
        )
        return try verifyKey.isValidSignature(
            secp256k1.Signing.ECDSASignature(dataRepresentation: signature.signature),
            for: data
        )
    }
    
    public func base64() -> String {
        return key.base64EncodedString()
    }
    
    public func hex() -> String {
        return "0x\(key.hexEncodedString())"
    }
    
    public func toSuiAddress() throws -> String {
        return normalizeSuiAddress(
            value: try Blake2.hash(
                .b2b,
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
        try suiBytes.set([SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["ED25519"]!])
        try suiBytes.set([UInt8](rawBytes), offset: 1)
        
        return [UInt8](suiBytes)
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

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PublicKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return try SECP256K1PublicKey(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
