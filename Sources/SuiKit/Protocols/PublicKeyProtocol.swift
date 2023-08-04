//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/20/23.
//

import Foundation

public protocol PublicKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    var key: Data { get }
    
    func verify(data: Data, signature: Signature) throws -> Bool
    func base64() -> String
    func hex() -> String
    func toSuiAddress() throws -> String
    func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool
    func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool
    func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool
}
