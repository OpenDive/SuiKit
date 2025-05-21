//
//  ZkLoginSigner.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
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

/// A signer that uses zkLogin to create and sign transactions
public class ZkLoginSigner {
    /// The Sui provider for network operations
    private let provider: SuiProvider
    
    /// The ephemeral keypair used for signing
    private let ephemeralKeyPair: Account
    
    /// The zkLogin signature structure
    private var zkLoginSignature: zkLoginSignature
    
    /// The user's zkLogin address
    private let userAddress: String
    
    /// Initialize a new ZkLoginSigner
    /// - Parameters:
    ///   - provider: The Sui provider for network operations
    ///   - ephemeralKeyPair: The ephemeral keypair used for signing
    ///   - zkLoginSignature: The zkLogin signature structure
    ///   - userAddress: The user's zkLogin address
    public init(
        provider: SuiProvider,
        ephemeralKeyPair: Account,
        zkLoginSignature: zkLoginSignature,
        userAddress: String
    ) {
        self.provider = provider
        self.ephemeralKeyPair = ephemeralKeyPair
        self.zkLoginSignature = zkLoginSignature
        self.userAddress = userAddress
    }
    
    /// Signs and executes a transaction using zkLogin authentication
    /// - Parameters:
    ///   - transactionBlock: The transaction to execute
    ///   - options: Optional execution parameters
    /// - Returns: The transaction execution response
    public func signAndExecuteTransaction(transactionBlock: inout TransactionBlock, options: SuiTransactionBlockResponseOptions = .init()) async throws -> SuiTransactionBlockResponse {
        // Ensure the transaction has the zkLogin user address as sender
        try transactionBlock.setSender(sender: userAddress)
        
        // Build the transaction
        let bytes = try await transactionBlock.build(self.provider)
        
        // Sign the transaction with the ephemeral keypair
        let userSignature = try ephemeralKeyPair.sign(bytes)
        
        // Update the zkLoginSignature with the user signature
        self.zkLoginSignature.userSignature = userSignature.signature.bytes
        
        // Get serialized signature
        let serializedSignature = try self.zkLoginSignature.getSignature()
        print("Sending zkLogin transaction with signature: \(serializedSignature)")
        
        // Execute the transaction with the zkLogin signature
        var resp = try await provider.executeTransactionBlock(
            transactionBlock: bytes.bytes,
            signature: serializedSignature,
            options: options
        )
        resp = try await provider.waitForTransaction(tx: resp.digest)
        return resp
    }
    
    /// Signs and executes a transaction block using zkLogin authentication
    /// - Parameters:
    ///   - transactionBlock: The transaction block to execute
    ///   - options: Optional execution parameters
    /// - Returns: The transaction execution response
    public func signAndExecuteTransactionBlock(transactionBlock: inout TransactionBlock, options: SuiTransactionBlockResponseOptions = .init()) async throws -> SuiTransactionBlockResponse {
        var txBlock = transactionBlock
        return try await signAndExecuteTransaction(transactionBlock: &txBlock, options: options)
    }
} 
