//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation
import secp256k1

public struct SECP256K1PrivateKey: Equatable, PrivateKeyProtocol {
    public typealias PrivateKeyType = SECP256K1PrivateKey
    public typealias PublicKeyType = SECP256K1PublicKey
    
    public var type: KeyType = .secp256k1
    
    /// The length of the key in bytes
    public static let LENGTH: Int = 32

    /// The key itself
    public var key: Data

    public init(key: Data) {
        self.key = key
    }

    public static func == (lhs: SECP256K1PrivateKey, rhs: SECP256K1PrivateKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return self.hex()
    }

    /// Converts the private key to a hexadecimal string.
    ///
    /// - Returns: A string representation of the private key in hexadecimal format, with a "0x" prefix.
    ///
    /// - Note: The hexEncodedString function of the Data type is called to convert the private key into a hexadecimal string, and "0x" is prepended to the resulting string.
    public func hex() -> String {
        return "0x" + self.key.hexEncodedString()
    }

    /// Creates a PrivateKey instance from a hex string.
    ///
    /// - Parameter value: A string representing the private key in hexadecimal format.
    ///
    /// - Returns: A PrivateKey instance representing the private key.
    ///
    /// - Note: The input string can optionally start with "0x". The string is converted into a Data instance using the hex initializer, and then used to create a new PrivateKey instance.
    public static func fromHex(_ value: String) -> SECP256K1PrivateKey {
        var hexValue = value
        if value.hasPrefix("0x") {
            hexValue = String(value.dropFirst(2))
        }
        let hexData = Data(hex: hexValue)
        return SECP256K1PrivateKey(key: hexData)
    }

    /// Calculates the corresponding public key for this private key instance using the Ed25519 algorithm.
    ///
    /// - Returns: A PublicKey instance representing the public key associated with this private key.
    ///
    /// - Throws: An error if the calculation of the public key fails, or if the public key cannot be used to create a PublicKey instance.
    ///
    /// - Note: The private key is converted into a UInt8 array and passed to the calcPublicKey function of the Ed25519 implementation. The resulting public key is then used to create a new PublicKey instance.
    public func publicKey() throws -> SECP256K1PublicKey {
        let key = try secp256k1.Signing.PrivateKey(rawRepresentation: self.key)
        return try SECP256K1PublicKey(data: key.publicKey.rawRepresentation)
    }

    /// Generates a new random private key using the Ed25519 algorithm.
    ///
    /// - Returns: A new PrivateKey instance with a randomly generated private key.
    ///
    /// - Throws: An error if the generation of the key pair fails or if the generated private key cannot be used to create a PrivateKey instance.
    ///
    /// - Note: The generateKeyPair function of the Ed25519 implementation is called to generate a new key pair, and the secret key is extracted and used to create a new PrivateKey instance.
    public static func random() throws -> SECP256K1PrivateKey {
        let privateKeyArray = try secp256k1.Signing.PrivateKey()
        return SECP256K1PrivateKey(key: Data(privateKeyArray.rawRepresentation))
    }

    /// Signs a message using this private key and the Ed25519 algorithm.
    ///
    /// - Parameter data: The message to be signed.
    ///
    /// - Returns: A Signature instance representing the signature for the message.
    ///
    /// - Throws: An error if the signing operation fails or if the resulting signature cannot be used to create a Signature instance.
    ///
    /// - Note: The input message is converted into a UInt8 array and passed to the sign function of the Ed25519 implementation along with the private key converted into a UInt8 array. The resulting signature is then used to create a new Signature instance.
    public func sign(data: Data) throws -> Signature {
        let privateKey = try secp256k1.Signing.PrivateKey(rawRepresentation: self.key)
        let signedMessage = try privateKey.signature(for: data)
        return Signature(signature: Data(signedMessage.rawRepresentation), publickey: try self.publicKey().key, signatureScheme: .SECP256K1)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PrivateKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return SECP256K1PrivateKey(key: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
