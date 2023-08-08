//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation
import secp256k1
import Bip39
import CryptoSwift
import BigInt
import Blake2
import CryptoKit

public struct SECP256K1PrivateKey: Equatable, PrivateKeyProtocol {
    public typealias PrivateKeyType = SECP256K1PrivateKey
    public typealias PublicKeyType = SECP256K1PublicKey
    
    public static let defaultDerivationPath: String = "m/54'/784'/0'/0/0"
    public static let curve: String = "Bitcoin seed"
    public static let secp256k1CurveOrder = BigUInt(
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
        radix: 16
    )!
    public static let hardenedOffset: UInt32 = 0x80000000
    
    /// The length of the key in bytes
    public static let LENGTH: Int = 32
    
    /// The key itself
    public var key: Data
    
    public init(key: Data) {
        self.key = key
    }
    
    public init(hexString: String) {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        self.key = Data(hex: hexValue)
    }
    
    public init() throws {
        let privateKeyArray = try secp256k1.Signing.PrivateKey()
        self.key = privateKeyArray.dataRepresentation
    }
    
    public init(_ mnemonics: String, _ path: String = SECP256K1PrivateKey.defaultDerivationPath) throws {
        guard SECP256K1PrivateKey.isValidBIP32Path(path) else { throw SuiError.invalidDerivationPath }
        let seedValue = try SECP256K1PrivateKey.mnemonicToSeed(mnemonics)
        if (seedValue.count * 8) < 128 || (seedValue.count * 8) > 512 { throw SuiError.notImplemented }
        let keys = try SECP256K1PrivateKey.fromMasterKey(seedValue)
        self.key = keys.key
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
        return "0x\(self.key.hexEncodedString())"
    }
    
    public func base64() -> String {
        return self.key.base64EncodedString()
    }
    
    /// Calculates the corresponding public key for this private key instance using the Ed25519 algorithm.
    ///
    /// - Returns: A PublicKey instance representing the public key associated with this private key.
    ///
    /// - Throws: An error if the calculation of the public key fails, or if the public key cannot be used to create a PublicKey instance.
    ///
    /// - Note: The private key is converted into a UInt8 array and passed to the calcPublicKey function of the Ed25519 implementation. The resulting public key is then used to create a new PublicKey instance.
    public func publicKey() throws -> SECP256K1PublicKey {
        let key = try secp256k1.Signing.PrivateKey(dataRepresentation: self.key)
        return try SECP256K1PublicKey(data: key.publicKey.dataRepresentation)
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
        let privateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: self.key)
        let signedMessage = try privateKey.signature(for: data)
        return Signature(
            signature: Data(signedMessage.dataRepresentation),
            publickey: try self.publicKey().key,
            signatureScheme: .SECP256K1
        )
    }
    
    public func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature {
        let intentMessage = messageWithIntent(intent, Data(bytes))
        let digest = try Blake2.hash(.b2b, size: 32, data: intentMessage)
        
        let signature = try self.sign(data: digest)
        return signature
    }
    
    public func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature {
        return try self.signWithIntent(bytes, .TransactionData)
    }
    
    public func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature {
        let ser = Serializer()
        try ser.sequence(bytes, Serializer.u8)
        return try self.signWithIntent([UInt8](ser.output()), .PersonalMessage)
    }

    private static func isValidBIP32Path(_ path: String) -> Bool {
        let pattern = "^m\\/(54|74)'\\/784'\\/[0-9]+'\\/[0-9]+\\/[0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex?.matches(in: path, options: [], range: NSRange(location: 0, length: path.utf16.count))
        
        return matches?.first != nil
    }

    private static func mnemonicToSeed(_ mnemonics: String) throws -> [UInt8] {
        let mnemonic = try Mnemonic(mnemonic: mnemonics.components(separatedBy: " "))
        return mnemonic.seed()
    }

    private static func fromMasterKey(_ seed: [UInt8]) throws -> Keys {
        guard let pathData = SECP256K1PrivateKey.curve.data(using: .ascii) else {
            throw SuiError.notImplemented
        }

        let hmac = HMAC(key: [UInt8](pathData), variant: .sha2(.sha512))
        let hmacBytes = try hmac.authenticate(seed)
        let key = Data(hmacBytes[..<32])
        let chainCode = Data(hmacBytes[32...])

        return Keys(key: key, chainCode: chainCode)
    }

//    private static func derive(_ keys: Keys, _ path: String) throws -> Keys {
////        struct keyDerivator:
//        
//        let test =
//    }

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PrivateKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return SECP256K1PrivateKey(key: key)
    }

    private struct Keys {
        public let key: Data
        public let chainCode: Data
        
        public init(key: Data, chainCode: Data) {
            self.key = key
            self.chainCode = chainCode
        }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
