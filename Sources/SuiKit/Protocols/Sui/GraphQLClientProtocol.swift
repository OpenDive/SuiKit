//
//  GraphQLClientProtocol.swift
//  SuiKit
//
//  Created by Marcus Arnett on 5/21/25.
//

public protocol GraphQLClientProtocol {
    /// Verify a zkLogin signature using GraphQL
    /// - Parameters:
    ///   - bytes: The message bytes (transaction data or personal message) as Base64
    ///   - signature: The zkLogin signature as Base64
    ///   - intentScope: The intent scope (transaction data or personal message)
    ///   - author: The address of the signer
    /// - Returns: The verification result
    func verifyZkLoginSignature(
        bytes: String,
        signature: String,
        intentScope: ZkLoginIntentScope,
        author: String
    ) async throws -> ZkLoginVerifyResult
}
