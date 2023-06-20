//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/20/23.
//

import Foundation

public protocol PrivateKeyProtocol: KeyProtocol, CustomStringConvertible {
    associatedtype PublicKeyType: PublicKeyProtocol
    associatedtype PrivateKeyType: PrivateKeyProtocol
    
    var type: KeyType { get }
    var key: Data { get }
    
    func hex() -> String
    func publicKey() throws -> PublicKeyType
    static func random() throws -> PrivateKeyType
    func sign(data: Data) throws -> Signature
}

public enum KeyType: String {
    case ed25519 = "ED25519"
    case secp256k1 = "SECP256K1"
    case secp256r1 = "SECP259R1"
}
