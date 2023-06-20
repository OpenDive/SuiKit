//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation
import secp256k1

public struct SECP256K1PublicKey: Equatable, PublicKeyProtocol {
    /// The length of the key in bytes
    public static let LENGTH: Int = 32
    
    public var type: KeyType = .secp256k1

    /// The key itself
    public var key: Data

    public init(data: Data) throws {
        guard data.count <= SECP256K1PublicKey.LENGTH else {
            throw SuiError.invalidPublicKey
        }
        self.key = data
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
    public func verify(data: Data, signature: Signature, _ privateKey: Data) throws -> Bool {
        let secpPrivateKey = try secp256k1.Signing.PrivateKey(rawRepresentation: privateKey)
        let secpSignature = try secpPrivateKey.signature(for: data)
        
        return secpPrivateKey.publicKey.isValidSignature(secpSignature, for: data)
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
