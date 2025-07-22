//
//  zkLoginPublicIdentifier.swift
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
import BigInt
import Blake2

public struct zkLoginPublicIdentifier: PublicKeyProtocol {
    public var key: Data
    private let client: GraphQLClientProtocol?

    public typealias DataValue = Data

    public static let LENGTH: Int = 32

    public init(data: Data) throws {
        guard data.count >= Self.LENGTH else {
            throw AccountError.invalidPublicKey
        }
        self.key = data
        self.client = nil
    }

    // Convenience initializer from zkLoginSignature for testing
    public init(data: zkLoginSignature) throws {
        // Extract issuer from signature 
        let issClaimJWT = zkLoginSignatureInputsClaim(
            value: data.inputs.issBase64Details.value,
            indexMod4: data.inputs.issBase64Details.indexMod4
        )
        let iss = try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss") as String

        // Initialize with address seed and issuer
        try self.init(addressSeed: BigInt(data.inputs.addressSeed)!, iss: iss, client: nil)
    }

    public init(addressSeed: BigInt, iss: String, client: GraphQLClientProtocol? = nil) throws {
        // In Rust, the ZkLoginPublicIdentifier is:
        // iss_bytes_len || iss_bytes || padded_32_byte_address_seed

        // Normalize the issuer string (ensure it has the https:// prefix for consistency)
        let normalizedIss = iss.hasPrefix("https://") ? iss : "https://\(iss)"

        let addressSeedBytes = zkLoginUtilities.toPaddedBigEndianBytes(num: addressSeed, width: Self.LENGTH)
        let issBytes = Data(normalizedIss.utf8)

        // Create data with format: iss_bytes_len || iss_bytes || padded_32_byte_address_seed
        var tmp = Data()
        tmp.append(UInt8(issBytes.count)) // First byte is issuer bytes length
        tmp.append(issBytes)              // Then the issuer bytes
        tmp.append(Data(addressSeedBytes)) // Then the padded 32-byte address seed

        self.key = tmp
        self.client = client
    }

    // Added overload for string addressSeed
    public init(addressSeed: String, iss: String, client: GraphQLClientProtocol? = nil) throws {
        // Try to convert the string addressSeed to BigInt
        guard let bigIntSeed = BigInt(addressSeed, radix: 10) else {
            throw AccountError.invalidData
        }
        try self.init(addressSeed: bigIntSeed, iss: iss, client: client)
    }

    // Manual Equatable conformance - only compare the key data, not the client
    public static func == (lhs: zkLoginPublicIdentifier, rhs: zkLoginPublicIdentifier) -> Bool {
        return lhs.key == rhs.key
    }

    // Manual Hashable conformance - only hash the key data, not the client
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public func base64() -> String {
        return key.base64EncodedString()
    }

    public func hex() -> String {
        return "0x\(self.key.hexEncodedString())"
    }

    public func toBase58() throws -> String {
        return try toSuiBytes().toBase58String()
    }

    public static func fromBase58(_ base58: String) throws -> zkLoginPublicIdentifier {
        guard let data = [UInt8](base58: base58) else {
            throw AccountError.invalidData
        }
        // Skip first byte (flag) and use the rest as the public key data
        guard data.count > 1 else {
            throw AccountError.invalidPublicKey
        }
        return try zkLoginPublicIdentifier(data: Data(data.dropFirst()))
    }

    public func toSuiAddress() throws -> String {
        return try Inputs.normalizeSuiAddress(
            value: try Blake2b.hash(
                size: 32,
                data: Data(try self.toSuiBytes())
            ).hexEncodedString()[0..<(32 * 2)]
        )
    }

    /// Converts the public key to a Sui address.
    /// - Throws: If any error occurs during conversion.
    /// - Returns: A string representing the Sui address.
    public func toSuiPublicKey() throws -> String {
        let bytes = try self.toSuiBytes()
        return bytes.toBase64()
    }

    /// Converts the public key to Sui bytes.
    /// - Throws: If any error occurs during conversion.
    /// - Returns: An array of bytes representing the Sui public key.
    public func toSuiBytes() throws -> [UInt8] {
        // Create a data structure with the format [flag_byte] + [zkLogin_identifier_bytes]
        var result = [UInt8]()
        result.append(SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["zkLogin"]!)
        result.append(contentsOf: [UInt8](self.key))

        return result
    }

    // Methods for zkLogin signature verification

    /// Verifies that the signature is valid for the provided transaction data
    public func verifyTransaction(transactionData: [UInt8], signature: zkLoginSignature) async throws -> Bool {
        guard let client = self.client else {
            throw SuiError.customError(message: "GraphQL client not provided for verification")
        }

        // Get the address from the signature components
        let address = try extractAddressFromSignature(signature: signature)

        // Convert transaction data to base64
        let transactionDataBase64 = Data(transactionData).base64EncodedString()

        // Serialize signature
        let serializedSignature = signature.serialize()

        // Call GraphQL verification
        guard let result = try? await client.verifyZkLoginSignature(
            bytes: transactionDataBase64,
            signature: serializedSignature,
            intentScope: .transactionData,
            author: address
        ) else {
            return false
        }

        return result.success && result.errors.isEmpty
    }

    /// Verifies that the signature is valid for the provided personal message
    public func verifyPersonalMessage(message: [UInt8], signature: zkLoginSignature) async throws -> Bool {
        guard let client = self.client else {
            throw SuiError.customError(message: "GraphQL client not provided for verification")
        }

        // Get the address from the signature components  
        let address = try extractAddressFromSignature(signature: signature)

        // Convert message to base64
        let messageBase64 = Data(message).base64EncodedString()

        // Serialize signature
        let serializedSignature = signature.serialize()

        // Call GraphQL verification
        let result = try await client.verifyZkLoginSignature(
            bytes: messageBase64,
            signature: serializedSignature,
            intentScope: .personalMessage,
            author: address
        )

        return result.success && result.errors.isEmpty
    }

    /// Extract the zkLogin address from a signature
    private func extractAddressFromSignature(signature: zkLoginSignature) throws -> String {
        // Extract issuer from the signature inputs
        let issClaimJWT = zkLoginSignatureInputsClaim(
            value: signature.inputs.issBase64Details.value,
            indexMod4: signature.inputs.issBase64Details.indexMod4
        )
        let iss = try JWTUtilities.extractClaimValue(claim: issClaimJWT, claimName: "iss") as String

        // Create a new public identifier from the signature data
        let publicKey = try zkLoginPublicIdentifier(
            addressSeed: BigInt(signature.inputs.addressSeed)!,
            iss: iss,
            client: self.client
        )

        return try publicKey.toSuiAddress()
    }

    public func verify(data: Data, signature: Signature) throws -> Bool {
        throw SuiError.customError(message: "Not implemented")
    }

    public func toSerializedSignature(signature: Signature) throws -> String {
        throw SuiError.customError(message: "Not implemented")
    }

    public func verifyTransactionBlock(_ transactionBlock: [UInt8], _ signature: Signature) throws -> Bool {
        throw SuiError.customError(message: "Not implemented")
    }

    public func verifyWithIntent(_ bytes: [UInt8], _ signature: Signature, _ intent: IntentScope) throws -> Bool {
        throw SuiError.customError(message: "Not implemented")
    }

    public func verifyPersonalMessage(_ message: [UInt8], _ signature: Signature) throws -> Bool {
        throw SuiError.customError(message: "Not implemented")
    }

    public static func deserialize(from deserializer: Deserializer) throws -> zkLoginPublicIdentifier {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != zkLoginPublicIdentifier.LENGTH {
            throw AccountError.lengthMismatch
        }
        return try zkLoginPublicIdentifier(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }

    public var description: String {
        self.hex()
    }
}

/// Provides functionality for generating zkLogin public keys and addresses
public struct zkLoginPublicKey {
    /// Generates a Sui address from zkLogin credentials
    /// - Parameters:
    ///   - keyClaimName: The name of the key claim (typically "sub")
    ///   - keyClaimValue: The value of the key claim (typically the user ID)
    ///   - issuer: The issuer of the JWT 
    ///   - audience: The audience value from the JWT
    ///   - userSalt: The user's salt value
    /// - Returns: A Sui address derived from the zkLogin credentials
    public static func deriveAddress(
        keyClaimName: String,
        keyClaimValue: String,
        issuer: String,
        audience: String,
        userSalt: String
    ) throws -> String {
        // Use existing zkLoginUtilities to compute the zkLogin address
        return try zkLoginUtilities.computezkLoginAddress(
            claimName: keyClaimName,
            claimValue: keyClaimValue,
            userSalt: userSalt,
            iss: issuer,
            aud: audience
        )
    }

    /// Creates a zkLoginPublicIdentifier from an address seed and issuer
    /// - Parameters:
    ///   - addressSeed: The address seed as a BigInt
    ///   - issuer: The issuer of the JWT
    /// - Returns: A zkLoginPublicIdentifier
    public static func createPublicIdentifier(
        addressSeed: BigInt,
        issuer: String
    ) throws -> zkLoginPublicIdentifier {
        return try zkLoginPublicIdentifier(
            addressSeed: addressSeed,
            iss: issuer
        )
    }
}
