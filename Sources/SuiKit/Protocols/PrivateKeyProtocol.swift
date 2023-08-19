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
