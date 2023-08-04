//
//  PrivateKey.swift
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
import CryptoSwift
import Bip39

/// The ED25519 Private Key
public struct ED25519PrivateKey: Equatable, PrivateKeyProtocol {
    public typealias PrivateKeyType = ED25519PrivateKey
    public typealias PublicKeyType = ED25519PublicKey
    
    /// The length of the key in bytes
    public static let LENGTH: Int = 32
    
    public static let hardenedOffset: UInt32 = 0x80000000
    public static let pathRegex: String = "^m(\\/[0-9]+')+$"
    public static let curve: String = "ed25519 seed"
    public static let defaultDerivationPath = "m/44'/784'/0'/0'/0'"
    public static let hardenedPathRegex = "^m\\/44'\\/784'\\/[0-9]+'\\/[0-9]+'\\/[0-9]+'+$"

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
    
    public init() {
        let privateKeyArray = Ed25519.generateKeyPair().secretKey
        self.key = Data(privateKeyArray)
    }
    
    public init(_ mnemonics: String, _ path: String = ED25519PrivateKey.defaultDerivationPath) throws {
        guard ED25519PrivateKey.isValidHardenedPath(path: path) else { throw SuiError.notImplemented }
        let key = try ED25519PrivateKey.derivePath(path, ED25519PrivateKey.mnemonicToSeedHex(mnemonics))
        self.key = key.key
    }

    public static func == (lhs: ED25519PrivateKey, rhs: ED25519PrivateKey) -> Bool {
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
    public func publicKey() throws -> PublicKeyType {
        let key = Ed25519.calcPublicKey(secretKey: [UInt8](self.key))
        return try ED25519PublicKey(data: Data(key))
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
        let signedMessage = Ed25519.sign(message: [UInt8](data), secretKey: [UInt8](self.key))
        return Signature(signature: Data(signedMessage), publickey: try self.publicKey().key)
    }
    
    private static func derivePath(
        _ path: String,
        _ seed: String,
        _ offset: UInt32 = ED25519PrivateKey.hardenedOffset
    ) throws -> Keys {
        guard ED25519PrivateKey.isValidPath(path) else { throw SuiError.invalidDerivationPath }
        
        let segments = path.split(separator: "/").dropFirst().map { component -> UInt32 in
            return UInt32(component.replacingOccurrences(of: "'", with: ""))! + offset
        }
        
        guard let curveData = ED25519PrivateKey.curve.data(using: .utf8) else { throw SuiError.notImplemented }
        guard let seedData = seed.data(using: .utf8) else { throw SuiError.notImplemented }
        
        var result = try self.hmacSha512(curveData, seedData)
        
        for next in segments {
            result = try self.getChildKeyDerivation(key: result.key, chainCode: result.chainCode, index: next)
        }
        
        return result
    }
    
    private static func getChildKeyDerivation(key: Data, chainCode: Data, index: UInt32) throws -> Keys {
        var buffer = Data()

        buffer.append(UInt8(0))
        buffer.append(key)
        let indexBytes = withUnsafeBytes(of: index.bigEndian) { Data($0) }
        buffer.append(indexBytes)

        return try self.hmacSha512(chainCode, buffer)
    }
    
    private static func hmacSha512(_ keyBuffer: Data, _ data: Data) throws -> Keys {
        let hmac = HMAC(key: keyBuffer.bytes, variant: .sha2(.sha512))
        let i = try hmac.authenticate(data.bytes)

        let il = Data(i[0..<32])
        let ir = Data(i[32...])

        return Keys(key: il, chainCode: ir)
    }
    
    private static func isValidPath(_ path: String) -> Bool {
        let pathRegex = try! NSRegularExpression(pattern: ED25519PrivateKey.pathRegex, options: .caseInsensitive)
        
        if pathRegex.firstMatch(
            in: path,
            options: [],
            range: NSRange(location: 0, length: path.utf16.count)
        ) == nil {
            return false
        }
        
        let components = path.split(separator: "/").map(String.init)
        
        for i in 1..<components.count {
            let replacedDerive = components[i].replacingOccurrences(of: "'", with: "")
            if Int(replacedDerive) == nil {
                return false
            }
        }
        
        return true
    }
    
    private static func isValidHardenedPath(path: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: ED25519PrivateKey.hardenedPathRegex, options: [])
        
        let range = NSRange(location: 0, length: path.utf16.count)
        let match = regex.firstMatch(in: path, options: [], range: range)
        
        return match != nil
    }

    private static func mnemonicToSeedHex(_ mnemonics: String) throws -> String {
        let mnemonic = try Mnemonic(mnemonic: mnemonics.components(separatedBy: " "))
        return mnemonic.seed().toHexString()
    }
    
    private struct Keys {
        public let key: Data
        public let chainCode: Data
        
        public init(key: Data, chainCode: Data) {
            self.key = key
            self.chainCode = chainCode
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ED25519PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != ED25519PrivateKey.LENGTH {
            throw SuiError.lengthMismatch
        }
        return ED25519PrivateKey(key: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
