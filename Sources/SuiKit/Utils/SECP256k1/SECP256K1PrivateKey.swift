//
//  SECP256K1PrivateKey.swift
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
import Bip39
import CryptoSwift
import BigInt
import Blake2
import CryptoKit
import secp256k1

/// `SECP256K1PrivateKey` is a struct representing a private key using the SECP256K1 elliptic curve cryptography.
public struct SECP256K1PrivateKey: Equatable, PrivateKeyProtocol {
    /// The type of the private key that corresponds to this private key.
    public typealias PrivateKeyType = SECP256K1PrivateKey
    public typealias PublicKeyType = SECP256K1PublicKey

    /// Default derivation path for the private key.
    public static let defaultDerivationPath: String = "m/54'/784'/0'/0/0"

    nonisolated(unsafe) static let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY))

    /// The length of the key in bytes
    public static let LENGTH: Int = 32

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
        guard let privateKeyArray = Self.generatePrivateKey() else { throw AccountError.invalidGeneratedKey }
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

    public func hex() -> String {
        return "0x\(self.key.hexEncodedString())"
    }

    public func base64() -> String {
        return self.key.base64EncodedString()
    }

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
        guard let result = Self.serializePublicKey(publicKey: &pubKeyObject, compressed: true) else { throw AccountError.invalidPubKeyCreation }
        return try SECP256K1PublicKey(data: result)
    }
    
    public static func generatePrivateKey() -> Data? {
        for _ in 0...1024 {
            guard let keyData = Self.randomBytes(length: 32) else {
                continue
            }
            guard Self.verifyPrivateKey(privateKey: keyData) else {
                continue
            }
            return keyData
        }
        return nil
    }
    
    public static func verifyPrivateKey(privateKey: Data) -> Bool {
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)), privateKey.count == 32 else { return false }
        let result = privateKey.withUnsafeBytes { privateKeyRBPointer -> Int32? in
            if let privateKeyRPointer = privateKeyRBPointer.baseAddress, privateKeyRBPointer.count > 0 {
                let privateKeyPointer = privateKeyRPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_seckey_verify(context, privateKeyPointer)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res == 1 else {
            return false
        }
        return true
    }
    
    public static func combineSerializedPublicKeys(keys: [Data], outputCompressed: Bool = false) -> Data? {
        let numToCombine = keys.count
        guard let context = context, numToCombine >= 1 else { return nil }
        var storage = ContiguousArray<secp256k1_pubkey>()
        let arrayOfPointers = UnsafeMutablePointer< UnsafePointer<secp256k1_pubkey>? >.allocate(capacity: numToCombine)
        defer {
            arrayOfPointers.deinitialize(count: numToCombine)
            arrayOfPointers.deallocate()
        }
        for i in 0 ..< numToCombine {
            let key = keys[i]
            guard let pubkey = Self.parsePublicKey(serializedKey: key) else { return nil }
            storage.append(pubkey)
        }
        for i in 0 ..< numToCombine {
            withUnsafePointer(to: &storage[i]) { ptr -> Void in
                arrayOfPointers.advanced(by: i).pointee = ptr
            }
        }
        let immutablePointer = UnsafePointer(arrayOfPointers)
        var publicKey: secp256k1_pubkey = secp256k1_pubkey()
        let result = withUnsafeMutablePointer(to: &publicKey) { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
            let res = secp256k1_ec_pubkey_combine(context, pubKeyPtr, immutablePointer, numToCombine)
            return res
        }
        if result == 0 {
            return nil
        }
        let serializedKey = Self.serializePublicKey(publicKey: &publicKey, compressed: outputCompressed)
        return serializedKey
    }
    
    public static func serializePublicKey(publicKey: inout secp256k1_pubkey, compressed: Bool = false) -> Data? {
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)) else { return nil }
        var keyLength = compressed ? 33 : 65
        var serializedPubkey = Data(repeating: 0x00, count: keyLength)
        let result = serializedPubkey.withUnsafeMutableBytes { serializedPubkeyRawBuffPointer -> Int32? in
            if let serializedPkRawPointer = serializedPubkeyRawBuffPointer.baseAddress, serializedPubkeyRawBuffPointer.count > 0 {
                let serializedPubkeyPointer = serializedPkRawPointer.assumingMemoryBound(to: UInt8.self)
                return withUnsafeMutablePointer(to: &keyLength) { (keyPtr: UnsafeMutablePointer<Int>) -> Int32 in
                    withUnsafeMutablePointer(to: &publicKey) { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
                        let res = secp256k1_ec_pubkey_serialize(
                            context,
                            serializedPubkeyPointer,
                            keyPtr,
                            pubKeyPtr,
                            UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED)
                        )
                        return res
                    }
                }
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return Data(serializedPubkey)
    }
    
    public static func privateToPublic(privateKey: Data, compressed: Bool = false) -> Data? {
        if privateKey.count != 32 { return nil }
        guard var publicKey = Self.privateKeyToPublicKey(privateKey: privateKey) else { return nil }
        guard let serializedKey = serializePublicKey(publicKey: &publicKey, compressed: compressed) else { return nil }
        return serializedKey
    }

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
        let digest = try Blake2b.hash(size: 32, data: intentMessage)
        
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

    /// The BIP32 path is a string representation used to derive keys from a seed in a hierarchical manner.
    /// - Parameters:
    ///   - path: A string representing the BIP32 path.
    /// - Returns: A boolean value, `true` if the given path is valid, `false` otherwise.
    /// - Note: The pattern for a valid BIP32 path for this function is "^m\\/(54|74)'\\/784'\\/[0-9]+'\\/[0-9]+\\/[0-9]+$".
    private static func isValidBIP32Path(_ path: String) -> Bool {
        let pattern = "^m\\/(54|74)'\\/784'\\/[0-9]+'\\/[0-9]+\\/[0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex?.matches(in: path, options: [], range: NSRange(location: 0, length: path.utf16.count))
        
        return matches?.first != nil
    }

    /// Converts a mnemonic string to a seed. A mnemonic is a human-readable representation of a seed, typically
    /// consisting of a sequence of randomly chosen words. The seed is a byte array generated from the mnemonic and
    /// is used to derive cryptographic keys.
    /// - Parameters:
    ///   - mnemonics: A string of space-separated words representing the mnemonic.
    /// - Returns: An array of bytes representing the derived seed.
    /// - Throws: If there is an error during the conversion of the mnemonic to a seed, an error will be thrown.
    private static func mnemonicToSeed(_ mnemonics: String) throws -> [UInt8] {
        let mnemonic = try Mnemonic(mnemonic: mnemonics.components(separatedBy: " "))
        return mnemonic.seed()
    }

    internal static func privateKeyToPublicKey(privateKey: Data) -> secp256k1_pubkey? {
        guard let context = context else { return nil }
        if privateKey.count != 32 { return nil }
        var publicKey = secp256k1_pubkey()
        let result = privateKey.withUnsafeBytes { (pkRawBufferPointer: UnsafeRawBufferPointer) -> Int32? in
            if let pkRawPointer = pkRawBufferPointer.baseAddress, pkRawBufferPointer.count > 0 {
                let privateKeyPointer = pkRawPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_create(context, &publicKey, privateKeyPointer)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return publicKey
    }

    internal static func parsePublicKey(serializedKey: Data) -> secp256k1_pubkey? {
        guard
            let context = context,
            (serializedKey.count == 33 || serializedKey.count == 65)
        else {
            return nil
        }
        let keyLen: Int = Int(serializedKey.count)
        var publicKey = secp256k1_pubkey()
        let result = serializedKey.withUnsafeBytes { (serializedKeyRawBufferPointer: UnsafeRawBufferPointer) -> Int32? in
            if let serializedKeyRawPointer = serializedKeyRawBufferPointer.baseAddress, serializedKeyRawBufferPointer.count > 0 {
                let serializedKeyPointer = serializedKeyRawPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_parse(context, &publicKey, serializedKeyPointer, keyLen)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return publicKey
    }

    internal static func randomBytes(length: Int) -> Data? {
        for _ in 0...1024 {
            var data = Data(repeating: 0, count: length)
            let result = data.withUnsafeMutableBytes { mutableRBBytes -> Int32? in
                if let mutableRBytes = mutableRBBytes.baseAddress, mutableRBBytes.count > 0 {
                    let mutableBytes = mutableRBytes.assumingMemoryBound(to: UInt8.self)
                    return SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
                } else {
                    return nil
                }
            }
            if let res = result, res == errSecSuccess {
                return data
            } else {
                continue
            }
        }
        return nil
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PrivateKey.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try SECP256K1PrivateKey(key: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
