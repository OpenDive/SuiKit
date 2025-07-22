//
//  zkLoginSignature.swift
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

public struct zkLoginSignature: KeyProtocol, Equatable {
    public var inputs: zkLoginSignatureInputs
    public var maxEpoch: UInt64
    public var userSignature: [UInt8]

    public init(inputs: zkLoginSignatureInputs, maxEpoch: UInt64, userSignature: [UInt8]) {
        self.inputs = inputs
        self.maxEpoch = maxEpoch
        self.userSignature = userSignature
    }

    public init(serializedData: Data) throws {
        let der = Deserializer(data: serializedData)
        let result = try zkLoginSignature.deserialize(from: der)
        self.init(inputs: result.inputs, maxEpoch: result.maxEpoch, userSignature: result.userSignature)
    }

    public func getSignatureBytes(signature: String? = nil) throws -> Data {
        let ser = Serializer()

        // Serialize the entire zkLoginSignature struct
        try self.serialize(ser)
        return ser.output()
    }

    public func getSignature() throws -> String {
        let bytes = try self.getSignatureBytes()
        var signatureBytes = Data(count: bytes.count + 1)
        signatureBytes[0] = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["zkLogin"]!
        signatureBytes[1..<(bytes.count + 1)] = bytes
        return signatureBytes.base64EncodedString()
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.inputs)
        try Serializer.u64(serializer, self.maxEpoch)
        try serializer.sequence(self.userSignature, Serializer.u8)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> zkLoginSignature {
        return zkLoginSignature(
            inputs: try Deserializer._struct(deserializer),
            maxEpoch: try Deserializer.u64(deserializer),
            userSignature: [UInt8](try Deserializer.toBytes(deserializer))
        )
    }

    /// Serialize the zkLogin signature for transaction submission
    /// - Returns: Base64 encoded serialized signature
    public func serialize() -> String {
        let serializer = Serializer()
        do {
            // First serialize the zkLoginSignature struct
            try self.serialize(serializer)
            let bytes = serializer.output()

            // Create result with signature scheme flag (0x05) as first byte
            var signatureBytes = Data(count: bytes.count + 1)
            signatureBytes[0] = SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["zkLogin"]!
            signatureBytes[1..<(bytes.count + 1)] = bytes

            // Convert to base64
            let base64Signature = signatureBytes.base64EncodedString()

            return base64Signature
        } catch {
            return Data().base64EncodedString() // Return empty signature in case of error
        }
    }

    /// Parse a serialized zkLogin signature string
    /// - Parameter serialized: Base64 encoded signature string
    /// - Returns: A zkLoginSignature instance
    public static func parse(serialized: String) throws -> zkLoginSignature {
        guard let data = Data(base64Encoded: serialized) else {
            throw SuiError.customError(message: "Failed to decode base64 signature")
        }

        // Verify signature prefix byte is correct (0x05 for zkLogin)
        guard data[0] == SignatureSchemeFlags.SIGNATURE_SCHEME_TO_FLAG["zkLogin"] else {
            throw SuiError.customError(message: "Invalid signature scheme flag")
        }

        // Skip the flag byte
        let signatureBytes = data.subdata(in: 1..<data.count)

        let deserializer = Deserializer(data: signatureBytes)

        // Deserialize the proof points structure
        let proofPoints = try zkLoginSignatureInputsProofPoints.deserialize(from: deserializer)

        // Deserialize issBase64Details
        let issBase64Details = try zkLoginSignatureInputsClaim.deserialize(from: deserializer)

        // Read headerBase64
        let headerBase64 = try Deserializer.string(deserializer)

        // Read addressSeed
        let addressSeed = try Deserializer.string(deserializer)

        // Create inputs struct
        let inputs = zkLoginSignatureInputs(
            proofPoints: proofPoints,
            issBase64Details: issBase64Details,
            headerBase64: headerBase64,
            addressSeed: addressSeed
        )

        // Read maxEpoch
        let maxEpoch = try Deserializer.u64(deserializer)

        // Read userSignature bytes
        let userSignature = try Deserializer.toBytes(deserializer)

        return zkLoginSignature(
            inputs: inputs,
            maxEpoch: maxEpoch,
            userSignature: [UInt8](userSignature)
        )
    }

    /// Verify this zkLogin signature against transaction data
    /// The verification must be performed externally as it requires GraphQL access
    /// - Parameters:
    ///   - transactionData: The transaction data to verify
    /// - Returns: True if verification can be initiated, but actual verification must be done externally
    public func verify(transactionData: [UInt8]) -> Bool {
        // This is just a placeholder - actual verification requires GraphQL
        // This simply confirms that we have all the necessary signature components
        return !self.serialize().isEmpty && !transactionData.isEmpty
    }

    /// Serialize a zkLogin signature to a string
    /// - Parameter signature: The signature to serialize
    /// - Returns: A serialized string representation
    public static func serialize(signature: zkLoginSignature) -> String {
        return signature.serialize()
    }
}

/// Default implementation of GraphQLClient
public class SuiGraphQLClient: GraphQLClientProtocol {
    private let url: URL
    private let session: URLSession

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    public func verifyZkLoginSignature(
        bytes: String,
        signature: String,
        intentScope: ZkLoginIntentScope,
        author: String
    ) async throws -> ZkLoginVerifyResult {
        // Construct GraphQL query matching the schema
        let query = """
        query verifyZkLoginSignature($bytes: Base64!, $signature: Base64!, $intentScope: ZkLoginIntentScope!, $author: SuiAddress!) {
          verifyZkloginSignature(
            bytes: $bytes,
            signature: $signature,
            intentScope: $intentScope,
            author: $author
          ) {
            success
            errors
          }
        }
        """

        // Create variables for the query
        let variables: [String: Any] = [
            "bytes": bytes,
            "signature": signature,
            "intentScope": intentScope.rawValue,
            "author": author
        ]

        // Create request body
        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables
        ]

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Send request
        let (data, response) = try await session.data(for: request)

        // Check response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SuiError.customError(message: "GraphQL request failed")
        }

        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SuiError.customError(message: "Invalid JSON response")
        }

        // Check for GraphQL errors first
        if let errors = json["errors"] as? [[String: Any]], !errors.isEmpty {
            let errorMessages = errors.compactMap { $0["message"] as? String }
            throw SuiError.customError(message: "GraphQL errors: \(errorMessages.joined(separator: ", "))")
        }

        // Extract verification result
        guard let dataJson = json["data"] as? [String: Any],
              let verifyResult = dataJson["verifyZkloginSignature"] as? [String: Any],
              let success = verifyResult["success"] as? Bool else {
            throw SuiError.customError(message: "Invalid GraphQL response format")
        }

        let errors = (verifyResult["errors"] as? [String]) ?? []

        return ZkLoginVerifyResult(success: success, errors: errors)
    }
}
