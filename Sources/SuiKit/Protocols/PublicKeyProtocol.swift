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
}
