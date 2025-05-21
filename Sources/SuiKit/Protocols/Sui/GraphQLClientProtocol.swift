//
//  GraphQLClientProtocol.swift
//  SuiKit
//
//  Created by Marcus Arnett on 5/21/25.
//

public protocol GraphQLClientProtocol {
    func verifyzkLoginSignature(
        signature: String,
        transactionData: [UInt8],
        currentEpoch: UInt64
    ) async throws -> Bool
}
