//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/20/23.
//

import Foundation

public protocol PublicKeyProtocol: KeyProtocol, CustomStringConvertible {
    var type: KeyType { get }
    var key: Data { get }
    
    func verify(data: Data, signature: Signature, _ privateKey: Data) throws -> Bool
}
