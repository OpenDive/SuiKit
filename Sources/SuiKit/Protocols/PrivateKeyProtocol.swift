//
//  File.swift
//
//
//  Created by Marcus Arnett on 6/20/23.
//

import Foundation
import Bip39

public protocol PrivateKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    associatedtype PublicKeyType: PublicKeyProtocol
    associatedtype PrivateKeyType: PrivateKeyProtocol

    var key: Data { get }
    
    func hex() -> String
    func base64() -> String
    func publicKey() throws -> PublicKeyType
    func sign(data: Data) throws -> Signature
    func signWithIntent(_ bytes: [UInt8], _ intent: IntentScope) throws -> Signature
    func signTransactionBlock(_ bytes: [UInt8]) throws -> Signature
    func signPersonalMessage(_ bytes: [UInt8]) throws -> Signature
}

public enum KeyType: String, Equatable {
    case ed25519 = "ED25519"
    case secp256k1 = "SECP256K1"
}

public let defaultEd25519DerivationPath = "m/44'/784'/0'/0'/0'"

public func isValidHardenedPath(path: String) -> Bool {
    let regex = try! NSRegularExpression(pattern: "^m\\/44'\\/784'\\/[0-9]+'\\/[0-9]+'\\/[0-9]+'+$", options: [])
    
    let range = NSRange(location: 0, length: path.utf16.count)
    let match = regex.firstMatch(in: path, options: [], range: range)
    
    return match != nil
}

public func mnemonicToSeedHex(_ mnemonics: String) throws -> String {
    let mnemonic = try Mnemonic(mnemonic: mnemonics.components(separatedBy: " "))
    return mnemonic.seed().toHexString()
}

//public func derivePath(_ path: String, _ seed: String, _ offset: Int = 2147483648) throws -> Keys {
//    return Keys(key: [0], chainCode: [0])
//}
