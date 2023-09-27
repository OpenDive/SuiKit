//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/21/23.
//

import Foundation

public struct ExportedAccount {
    /// Represents the key type/schema of the exported account.
    public let schema: KeyType

    /// Represents the private key of the exported account, stored as a string.
    public let privateKey: String

    /// Initializes a new instance of the `ExportedAccount` structure.
    ///
    /// - Parameters:
    ///   - schema: The key type/schema of the account.
    ///   - privateKey: The private key of the account as a string.
    public init(schema: KeyType, privateKey: String) {
        self.schema = schema
        self.privateKey = privateKey
    }
}
