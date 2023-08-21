//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation
import Bip39
import CryptoSwift
import BigInt
import Blake2
import CryptoKit
import Web3Core
import secp256k1

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

    public init(key: Data) throws {
        guard key.count == Self.LENGTH else {
            throw AccountError.invalidLength
        }
        self.key = key
    }

    public init(hexString: String) {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        self.key = Data(hex: hexValue)
    }

    public init(value: String) throws {
        guard let data = Data.fromBase64(value) else { throw AccountError.invalidData }
        self.key = data
    }

    public init() throws {
        guard let privateKeyArray = SECP256K1.generatePrivateKey() else { throw AccountError.invalidGeneratedKey }
        self.key = privateKeyArray
    }

    public init(_ mnemonics: String, _ path: String = SECP256K1PrivateKey.defaultDerivationPath) throws {
        guard SECP256K1PrivateKey.isValidBIP32Path(path) else { throw AccountError.invalidDerivationPath }
        let seedValue = try SECP256K1PrivateKey.mnemonicToSeed(mnemonics)
        if (seedValue.count * 8) < 128 || (seedValue.count * 8) > 512 { throw AccountError.invalidMnemonicSeed }
        guard let node = HDNode(seed: Data(seedValue))?.derive(path: path, derivePrivateKey: true), let privateKey = node.privateKey else {
            throw AccountError.invalidHDNode
        }
        self.key = privateKey
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
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)) else { throw AccountError.invalidContext }
        var pubKeyObject: secp256k1_pubkey = secp256k1_pubkey()
        let pubKeyResult = self.key.withUnsafeBytes { (rawUnsafePubkeyPtr: UnsafeRawBufferPointer) -> Int32? in
            if let rawPubKey = rawUnsafePubkeyPtr.baseAddress, rawUnsafePubkeyPtr.count > 0 {
                let pubKeyPtr = rawPubKey.assumingMemoryBound(to: UInt8.self)
                return withUnsafeMutablePointer(to: &pubKeyObject) { (mutablePubKey: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32? in
                    let res = secp256k1_ec_pubkey_create(ctx, mutablePubKey, pubKeyPtr)
                    return res
                }
            } else {
                return nil
            }
        }
        guard let _ = pubKeyResult else { throw AccountError.invalidPubKeyCreation }
        guard let result = SECP256K1.serializePublicKey(publicKey: &pubKeyObject, compressed: true) else { throw AccountError.invalidPubKeyCreation }
        return try SECP256K1PublicKey(data: result)
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
        let hash = data.sha256
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)) else { throw AccountError.invalidContext }
        var signatureReturned: secp256k1_ecdsa_signature = secp256k1_ecdsa_signature()
        let result = hash.withUnsafeBytes { hashRBPointer -> Int32? in
            if let hashRPointer = hashRBPointer.baseAddress, hashRBPointer.count > 0 {
                let hashPointer = hashRPointer.assumingMemoryBound(to: UInt8.self)
                return self.key.withUnsafeBytes { privateKeyRBPointer -> Int32? in
                    if let privateKeyRPointer = privateKeyRBPointer.baseAddress, privateKeyRBPointer.count > 0 {
                        let privateKeyPointer = privateKeyRPointer.assumingMemoryBound(to: UInt8.self)
                        return withUnsafeMutablePointer(
                            to: &signatureReturned
                        ) { (recSignaturePtr: UnsafeMutablePointer<secp256k1_ecdsa_signature>) -> Int32? in
                            let res = secp256k1_ecdsa_sign(ctx, recSignaturePtr, hashPointer, privateKeyPointer, nil, nil)
                            return res
                        }
                    } else {
                        return nil
                    }
                }
            } else {
                return nil
            }
        }
        guard result != nil, result != 0 else { throw AccountError.invalidSignature }
        var serializedSignature = Data(repeating: 0x00, count: 64)
        let compactResult = serializedSignature.withUnsafeMutableBytes { (signatureRBPtr: UnsafeMutableRawBufferPointer) -> Int32? in
            if let signatureRP = signatureRBPtr.baseAddress, signatureRBPtr.count > 0 {
                let typedSignaturePtr = signatureRP.assumingMemoryBound(to: UInt8.self)
                return withUnsafePointer(to: &signatureReturned) { (signaturePtr: UnsafePointer<secp256k1_ecdsa_signature>) -> Int32 in
                    let res = secp256k1_ecdsa_signature_serialize_compact(ctx, typedSignaturePtr, signaturePtr)
                    return res
                }
            } else {
                return nil
            }
        }
        guard compactResult != nil, compactResult != 0 else { throw AccountError.invalidSerializedSignature }
        return Signature(
            signature: serializedSignature,
            publickey: try self.publicKey().key,
            signatureScheme: .SECP256K1
        )
    }

    public func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature {
        let intentMessage = RawSigner.messageWithIntent(intent, Data(bytes))
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

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PrivateKey.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try SECP256K1PrivateKey(key: key)
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
