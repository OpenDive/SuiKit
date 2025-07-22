//
//  SuiProvider.swift
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
import SwiftyJSON
@preconcurrency import AnyCodable
import Blake2
import BigInt

/// The RPC Provider used to interact with the Sui blockchain.
public struct SuiProvider {
    /// A property representing the connection to a provider that conforms to the `ConnectionProtocol`.
    /// This connection is used to interact with the Sui network, allowing for the execution of various
    /// network-related tasks such as fetching data, sending requests, etc.
    public var connection: any ConnectionProtocol

    public init(connection: any ConnectionProtocol) {
        self.connection = connection
    }

    /// Runs the transaction in dev-inspect mode. Which allows for nearly any transaction (or Move call) with any arguments. Detailed results are provided, including both the transaction effects and any return values.
    /// - Parameters:
    ///   - transactionBlock: BCS encoded TransactionKind(as opposed to TransactionData, which include gasBudget and gasPrice).
    ///   - sender: The account that sends the transaction.
    ///   - gasPrice: Gas is not charged, but gas usage is still calculated. Default to use reference gas price.
    ///   - epoch: The epoch to perform the call. Will be set from the system state object if not provided.
    /// - Returns: The results of the inspection, encapsulated in a `DevInspectResults` object, if successful.
    /// - Throws: Throws an error if inspection fails, or if any error occurs during the process.
    public func devInspectTransactionBlock(
        transactionBlock: inout TransactionBlock,
        sender: Account,
        gasPrice: Int? = nil,
        epoch: String? = nil
    ) async throws -> DevInspectResults? {
        let senderAddress = try sender.publicKey.toSuiAddress()
        try transactionBlock.setSenderIfNotSet(sender: senderAddress)
        let result = try await transactionBlock.build(self, true)
        let devInspectTxBytes = result.base64EncodedString()
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_devInspectTransactionBlock",
                [
                    AnyCodable(senderAddress),
                    AnyCodable(devInspectTxBytes),
                    AnyCodable(gasPrice),
                    AnyCodable(epoch)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return DevInspectResults(input: JSON(data)["result"])
    }

    /// Return transaction execution effects including the gas cost summary, while the effects are not committed to the chain.
    /// - Parameter transactionBlock: The bytes representing the transaction block to be dry run.
    /// - Returns: A `SuiTransactionBlockResponse` representing the outcome of the dry run.
    /// - Throws: Throws an error if the dry run fails or if any error occurs during the process.
    public func dryRunTransactionBlock(
        transactionBlock: [UInt8]
    ) async throws -> SuiTransactionBlockResponse {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_dryRunTransactionBlock",
                [
                    AnyCodable(transactionBlock.toBase64())
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    /// Function to sign and execute a transaction block, making the transactions within
    /// the block occur on the blockchain.
    /// - Parameters:
    ///   - transactionBlock: The transaction block to be signed and executed.
    ///   - signer: The account that signs the transaction block.
    ///   - options: Additional options for the response of the executed transaction block.
    ///   - requestType: The type of the Sui request being made.
    /// - Returns: A `SuiTransactionBlockResponse` representing the outcome of the executed transaction block.
    /// - Throws: Throws an error if signing or executing the transaction block fails, or if any error occurs during the process.
    public func signAndExecuteTransactionBlock(
        transactionBlock: inout TransactionBlock,
        signer: Account,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        try transactionBlock.setSenderIfNotSet(sender: try signer.publicKey.toSuiAddress())
        let txBytes = try await transactionBlock.build(self)
        let signature = try signer.signTransactionBlock([UInt8](txBytes))
        return try await self.executeTransactionBlock(
            transactionBlock: [UInt8](txBytes),
            signature: try signer.toSerializedSignature(signature),
            options: options,
            requestType: requestType
        )
    }

    /// Execute the transaction and wait for results if desired. Request types: 1. WaitForEffectsCert: waits for TransactionEffectsCert and then return to client.
    ///
    /// This mode is a proxy for transaction finality. 2. WaitForLocalExecution: waits for TransactionEffectsCert and make sure the node executed the transaction
    /// locally before returning the client. The local execution makes sure this node is aware of this transaction when client fires subsequent queries.
    /// However if the node fails to execute the transaction locally in a timely manner, a bool type in the response is set to false to indicated the case.
    /// request_type is default to be `WaitForEffectsCert` unless options.show_events or options.show_effects is true.
    /// - Parameters:
    ///   - transactionBlock: BCS serialized transaction data bytes without its type tag, as base-64 encoded string.
    ///   - signature: A list of signatures (`flag || signature || pubkey` bytes, as base-64 encoded string). Signature is committed to the intent message of the transaction data, as base-64 encoded string.
    ///   - options: options for specifying the content to be returned
    ///   - requestType: The request type, derived from `SuiTransactionBlockResponseOptions` if None
    /// - Returns: A `SuiTransactionBlockResponse` representing the outcome of the executed transaction block.
    /// - Throws: Throws an error if executing the transaction block fails or if any error occurs during the process.
    public func executeTransactionBlock(
        transactionBlock: String,
        signature: String,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_executeTransactionBlock",
                [
                    AnyCodable(transactionBlock),
                    AnyCodable([signature]),
                    AnyCodable(options),
                    AnyCodable(requestType)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    /// Execute the transaction and wait for results if desired. Request types: 1. WaitForEffectsCert: waits for TransactionEffectsCert and then return to client.
    ///
    /// This mode is a proxy for transaction finality. 2. WaitForLocalExecution: waits for TransactionEffectsCert and make sure the node executed the transaction
    /// locally before returning the client. The local execution makes sure this node is aware of this transaction when client fires subsequent queries.
    /// However if the node fails to execute the transaction locally in a timely manner, a bool type in the response is set to false to indicated the case.
    /// request_type is default to be `WaitForEffectsCert` unless options.show_events or options.show_effects is true.
    /// - Parameters:
    ///   - transactionBlock: BCS serialized transaction data bytes without its type tag, as base-64 encoded string.
    ///   - signature: A list of signatures (`flag || signature || pubkey` bytes, as base-64 encoded string). Signature is committed to the intent message of the transaction data, as base-64 encoded string.
    ///   - options: options for specifying the content to be returned
    ///   - requestType: The request type, derived from `SuiTransactionBlockResponseOptions` if None
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiTransactionBlockResponse` containing the results of the executed transaction block.
    public func executeTransactionBlock(
        transactionBlock: [UInt8],
        signature: String,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_executeTransactionBlock",
                [
                    AnyCodable(transactionBlock.toBase64()),
                    AnyCodable([signature]),
                    AnyCodable(options),
                    AnyCodable(requestType)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    /// Return the first four bytes of the chain's genesis checkpoint digest.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `String` representing the chain identifier.
    public func getChainIdentifier() async throws -> String {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getChainIdentifier",
                []
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return JSON(data)["result"].stringValue
    }

    /// Return a checkpoint.
    /// - Parameter id: Checkpoint identifier, can use either checkpoint digest, or checkpoint sequence number as input.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `Checkpoint` object representing the retrieved checkpoint.
    public func getCheckpoint(id: String) async throws -> Checkpoint {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getCheckpoint",
                [
                    AnyCodable(id)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let value = JSON(data)["result"]
        return Checkpoint(input: value)
    }

    /// Return paginated list of checkpoints.
    /// - Parameters:
    ///   - cursor: An optional paging cursor. If provided, the query will start from the next item after the specified cursor. Default to start from the first item if not specified.
    ///   - limit: Maximum item returned per page, default to [QUERY_MAX_RESULT_LIMIT_CHECKPOINTS] if not specified.
    ///   - order: A `SortOrder` enum value indicating the order of the results, defaulting to descending, defaults to ascending order, oldest record first.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `CheckpointPage` object containing a list of retrieved checkpoints and pagination information.
    public func getCheckpoints(
        cursor: String? = nil,
        limit: Int? = nil,
        order: SortOrder = .descending
    ) async throws -> CheckpointPage {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getCheckpoints",
                [
                    AnyCodable(cursor),
                    AnyCodable(limit),
                    AnyCodable(order == .descending ? true : false)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        var checkpointPages: [Checkpoint] = []
        let result = JSON(data)["result"]
        for checkpoint in result["data"].arrayValue {
            checkpointPages.append(Checkpoint(input: checkpoint))
        }
        return CheckpointPage(
            data: checkpointPages,
            nextCursor: result["nextCursor"].stringValue,
            hasNextPage: result["hasNextPage"].boolValue
        )
    }

    /// Return transaction events.
    /// - Parameter transactionDigest: The digest of the transaction for which to retrieve events.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `PaginatedSuiMoveEvent` object containing a list of retrieved events and pagination information.
    public func getEvents(
        transactionDigest: String
    ) async throws -> PaginatedSuiMoveEvent {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getEvents",
                [
                    AnyCodable(transactionDigest)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        var eventPages: [SuiEvent] = []
        let result = JSON(data)["result"]
        for event in result.arrayValue {
            guard let eventUnwrapped = SuiEvent(input: event) else { continue }
            eventPages.append(eventUnwrapped)
        }
        return PaginatedSuiMoveEvent(
            data: eventPages,
            nextCursor: EventId.parseJSON(result["nextCursor"]),
            hasNextPage: result["hasNextPage"].boolValue
        )
    }

    /// Return the sequence number of the latest checkpoint that has been executed.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `String` representing the latest checkpoint sequence number.
    public func getLatestCheckpointSequenceNumber() async throws -> String {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getLatestCheckpointSequenceNumber", [])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return JSON(data)["result"].stringValue
    }

    /// Retrieves the loaded child objects associated with a given digest from the Sui blockchain.
    /// - Parameter digest: The digest string of the parent object.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `TransactionEffectsModifiedAtVersions` representing the loaded child objects.
    public func getLoadedChildObjects(
        digest: String
    ) async throws -> [TransactionEffectsModifiedAtVersions] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getLoadedChildObjects", [AnyCodable(digest)])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return result.arrayValue.map { TransactionEffectsModifiedAtVersions(input: $0) }
    }

    /// Return the argument types of a Move function, based on normalized Type.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module and function.
    ///   - module: The string identifier of the module containing the function.
    ///   - function: The string identifier of the function whose argument types are to be retrieved.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `SuiMoveFunctionArgType` representing the argument types of the specified Move function.
    public func getMoveFunctionArgTypes(
        package: String,
        module: String,
        function: String
    ) async throws -> [SuiMoveFunctionArgType] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getMoveFunctionArgTypes",
                [
                    AnyCodable(package),
                    AnyCodable(module),
                    AnyCodable(function)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        var argTypes: [SuiMoveFunctionArgType] = []
        for arg in result.arrayValue {
            if arg.stringValue == "Pure" {
                argTypes.append(.pure)
            } else {
                if let object = ObjectValueKind(rawValue: arg["Object"].stringValue) {
                    argTypes.append(.object(object))
                }
            }
        }
        return argTypes
    }

    /// Return a structured representation of Move function.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module and function.
    ///   - moduleName: The string identifier of the module containing the function.
    ///   - functionName: The string identifier of the function to be normalized.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedFunction` object representing the normalized representation of the specified Move function, or `nil` if not found.
    public func getNormalizedMoveFunction(
        package: String,
        moduleName: String,
        functionName: String
    ) async throws -> SuiMoveNormalizedFunction? {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getNormalizedMoveFunction",
                [
                    AnyCodable(package),
                    AnyCodable(moduleName),
                    AnyCodable(functionName)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return SuiMoveNormalizedFunction(input: result)
    }

    /// Return a structured representation of Move module.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module.
    ///   - module: The string identifier of the module to be normalized.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedModule` object representing the normalized representation of the specified Move module, or `nil` if not found.
    public func getNormalizedMoveModule(
        package: String,
        module: String
    ) async throws -> SuiMoveNormalizedModule? {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getNormalizedMoveModule",
                [
                    AnyCodable(package),
                    AnyCodable(module)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return SuiMoveNormalizedModule(input: result)
    }

    /// Return structured representations of all modules in the given package.
    /// - Parameter package: The string identifier of the package containing the modules.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedModules` object representing the normalized representation of the specified Move modules.
    public func getNormalizedMoveModulesByPackage(
        package: String
    ) async throws -> SuiMoveNormalizedModules {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getNormalizedMoveModulesByPackage",
                [
                    AnyCodable(package)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return try self.parseNormalizedModules(result: result)
    }

    /// Return a structured representation of Move struct.
    /// - Parameters:
    ///   - package: The string identifier of the package containing the module and struct.
    ///   - module: The string identifier of the module containing the struct.
    ///   - structure: The string identifier of the struct to be normalized.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiMoveNormalizedStruct` object representing the normalized representation of the specified Move struct, or `nil` if not found.
    public func getNormalizedMoveStruct(
        package: String,
        module: String,
        structure: String
    ) async throws -> SuiMoveNormalizedStruct? {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getNormalizedMoveStruct",
                [
                    AnyCodable(package),
                    AnyCodable(module),
                    AnyCodable(structure)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return SuiMoveNormalizedStruct(input: result)
    }

    /// Return the object information for a specified object.
    /// - Parameters:
    ///   - objectId: The string identifier of the object to be retrieved.
    ///   - options: The optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if the address is invalid or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiObjectResponse` object representing the retrieved Sui object, or `nil` if not found.
    public func getObject(
        objectId: String,
        options: SuiObjectDataOptions? = nil
    ) async throws -> SuiObjectResponse? {
        guard (try Inputs.normalizeSuiAddress(value: objectId)).isValidSuiAddress() else { throw SuiError.customError(message: "Unable to validate address") }
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getObject",
                [
                    AnyCodable(objectId),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let value = JSON(data)["result"]
        return SuiObjectResponse(input: value)
    }

    /// Return the protocol config table for the given version number. If the version number is not specified, If none is specified, the node uses the version of the latest epoch it has processed.
    /// - Parameter version: An optional protocol version specifier. If omitted, the latest protocol config table for the node will be returned.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `ProtocolConfig` object representing the protocol configuration.
    public func getProtocolConfig(
        version: String? = nil
    ) async throws -> ProtocolConfig {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getProtocolConfig",
                [
                    AnyCodable(version)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        var attributesDict: [String: ProtocolConfigValue?] = [:]
        let attributeTypeMap: [String: (String) -> ProtocolConfigValue] = [
            "u64": { .u64($0) },
            "u32": { .u32($0) },
            "f64": { .f64($0) }
        ]
        for (attribute, details) in result["attributes"].dictionaryValue {
            for (type, attributeCase) in attributeTypeMap {
                if let value = details[type].string {
                    attributesDict[attribute] = attributeCase(value)
                    break
                }
            }
        }
        return ProtocolConfig(
            attributes: attributesDict,
            featureFlags: result["featureFlags"].dictionaryObject as! [String: Bool],
            maxSupportedProtocolVersion: result["maxSupportedProtocolVersion"].stringValue,
            minSupportedProtocolVersion: result["minSupportedProtocolVersion"].stringValue,
            protocolVersion: result["protocolVersion"].stringValue
        )
    }

    /// Return the total number of transaction blocks known to the server.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `UInt64` representing the total number of transaction blocks.
    public func getTotalTransactionBlocks() async throws -> BigInt {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getTotalTransactionBlocks", [])
        )
        return BigInt(JSON(data)["result"].stringValue, radix: 10)!
    }

    /// Return the transaction response object.
    /// - Parameters:
    ///   - digest: A `String` representing the digest of the queried transaction.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if the digest is invalid or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: A `SuiTransactionBlockResponse` object representing the retrieved transaction block.
    public func getTransactionBlock(
        digest: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> SuiTransactionBlockResponse {
        guard self.isValidTransactionDigest(digest) else { throw SuiError.customError(message: "Invalid digest") }
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getTransactionBlock",
                [
                    AnyCodable(digest),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    /// Return the object data for a list of objects.
    /// - Parameters:
    ///   - ids: An array of `objectId` representing the ids of the objects to be retrieved.
    ///   - options: An optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if any address is invalid or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `SuiObjectResponse` representing the retrieved Sui objects.
    public func getMultiObjects(
        ids: [ObjectId],
        options: SuiObjectDataOptions? = nil
    ) async throws -> [SuiObjectResponse] {
        for object in ids {
            guard (try Inputs.normalizeSuiAddress(value: object)).isValidSuiAddress() else {
                throw SuiError.customError(message: "Unable to validate address")
            }
        }
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_multiGetObjects",
                [
                    AnyCodable(ids),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let jsonResponse = JSON(data)["result"]
        var objectResponses: [SuiObjectResponse] = []
        for jsonData in jsonResponse.arrayValue {
            guard let object = SuiObjectResponse(input: jsonData) else { continue }
            objectResponses.append(object)
        }
        return objectResponses
    }

    /// Returns an ordered list of transaction responses The method will throw an error if the input contains any duplicate or the input size exceeds `QUERY_MAX_RESULT_LIMIT`.
    /// - Parameters:
    ///   - digests: An array of `String` representing the digests of the transaction blocks to be retrieved.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if any digest is invalid, if there are duplicate digests, or if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `SuiTransactionBlockResponse` representing the retrieved transaction blocks.
    public func multiGetTransactionBlocks(
        digests: [String],
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> [SuiTransactionBlockResponse] {
        for digest in digests {
            guard self.isValidTransactionDigest(digest) else { throw SuiError.customError(message: "Invalid digest") }
        }
        guard digests.count == Set(digests).count else { throw SuiError.customError(message: "Digest do not match: \(digests.count) != \(Set(digests).count)") }
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_multiGetTransactionBlocks",
                [
                    AnyCodable(digests),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        return JSON(data)["result"].arrayValue.map { SuiTransactionBlockResponse(input: $0) }
    }

    /// Return the object information for a specified version.
    ///
    /// There is no software-level guarantee/SLA that objects with past versions can be retrieved by this API, even if the object and version exists/existed. The result may vary across nodes depending on their pruning policies.
    /// - Parameters:
    ///   - id: A `String` representing the id of the object to be retrieved.
    ///   - version: An `Int` representing the version of the object to be retrieved.
    ///   - options: An optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An `ObjectRead` object representing the retrieved past object, or `nil` if not found.
    public func tryGetPastObject(
        id: String,
        version: Int,
        options: SuiObjectDataOptions? = nil
    ) async throws -> ObjectRead? {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_tryGetPastObject",
                [
                    AnyCodable(id),
                    AnyCodable(version),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return ObjectRead.parseJSON(result)
    }

    /// Return the object information for a specified version.
    ///
    /// There is no software-level guarantee/SLA that objects with past versions can be retrieved by this API, even if the object and version exists/existed. The result may vary across nodes depending on their pruning policies.
    /// - Parameters:
    ///   - objects: An array of `GetPastObjectRequest` representing the requests for the objects to be retrieved.
    ///   - options: An optional `SuiObjectDataOptions` to customize the retrieval.
    /// - Throws: A `SuiError` if an error occurs during the JSON RPC call or if there are errors in the response data.
    /// - Returns: An array of `ObjectRead` representing the retrieved past objects.
    public func tryMultiGetPastObjects(
        objects: [GetPastObjectRequest],
        options: SuiObjectDataOptions? = nil
    ) async throws -> [ObjectRead] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_tryMultiGetPastObjects",
                [
                    AnyCodable(objects),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return result.arrayValue.compactMap { ObjectRead.parseJSON($0) }
    }

    /// Return the total coin balance for all coin type, owned by the address owner.
    /// - Parameter account: The account whose balances are to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: An array of `CoinBalance` representing the balances of different coins in the account.
    public func getAllBalances(
        account: Account
    ) async throws -> [CoinBalance] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllBalances", [
                AnyCodable(try account.publicKey.toSuiAddress())
            ])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        var balances: [CoinBalance] = []
        for (_, value): (String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"] {
            let lockedBalance = value["lockedBalance"]
            balances.append(
                try CoinBalance(
                    coinType: value["coinType"].stringValue,
                    coinObjectCount: value["coinObjectCount"].intValue,
                    totalBalance: value["totalBalance"].stringValue,
                    lockedBalance: value["lockedBalance"].isEmpty ? nil : LockedBalance(
                        epochId: lockedBalance["epochId"].intValue,
                        number: lockedBalance["number"].intValue
                    )
                )
            )
        }
        return balances
    }

    /// Return all Coin objects owned by an address.
    /// - Parameters:
    ///   - account: Any object conforming to `PublicKeyProtocol` whose associated coins are to be retrieved.
    ///   - cursor: Optional. A cursor for pagination.
    ///   - limit: Optional. A limit on the number of coins to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: A `PaginatedCoins` object containing the retrieved coins and pagination information.
    public func getAllCoins(
        account: any PublicKeyProtocol,
        cursor: String? = nil,
        limit: UInt? = nil
    ) async throws -> PaginatedCoins {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllCoins", [
                AnyCodable(try account.toSuiAddress()),
                AnyCodable(cursor),
                AnyCodable(limit)
            ])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        var coinPages: [CoinStruct] = []
        let result = try JSONDecoder().decode(JSON.self, from: data)["result"]
        for (_, value): (String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"]["data"] {
            coinPages.append(
                try CoinStruct(
                    coinType: value["coinType"].stringValue,
                    coinObjectId: value["coinObjectId"].stringValue,
                    version: value["version"].stringValue,
                    digest: value["digest"].stringValue,
                    balance: value["balance"].stringValue,
                    previousTransaction: value["previousTransaction"].stringValue
                )
            )
        }
        return PaginatedCoins(
            data: coinPages,
            nextCursor: result["nextCursor"].stringValue,
            hasNextPage: result["hasNextPage"].boolValue
        )
    }

    /// Return the total coin balance for one coin type, owned by the address owner.
    /// - Parameters:
    ///   - account: Any object conforming to `PublicKeyProtocol` whose balance is to be retrieved.
    ///   - coinType: Optional. The type of the coin whose balance is to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: A `CoinBalance` object representing the balance of the specified coin in the account.
    public func getBalance(
        account: any PublicKeyProtocol,
        coinType: String? = nil
    ) async throws -> CoinBalance {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getBalance", [
                AnyCodable(try account.toSuiAddress()),
                AnyCodable(coinType)
            ])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        let lockedBalance = value["lockedBalance"]
        return try CoinBalance(
            coinType: value["coinType"].stringValue,
            coinObjectCount: value["coinObjectCount"].intValue,
            totalBalance: value["totalBalance"].stringValue,
            lockedBalance: value["lockedBalance"].isEmpty ? nil : LockedBalance(
                epochId: lockedBalance["epochId"].intValue,
                number: lockedBalance["number"].intValue
            )
        )
    }

    /// Return metadata (e.g., symbol, decimals) for a coin.
    /// - Parameter coinType: type name for the coin (e.g., 0x168da5bf1f48dafc111b0a488fa454aca95e0b5e::usdc::USDC)
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response, or if the coinType is invalid.
    /// - Returns: A `SuiCoinMetadata` object representing the metadata of the specified coin.
    public func getCoinMetadata(
        coinType: String
    ) async throws -> SuiCoinMetadata {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getCoinMetadata",
                [
                    AnyCodable(coinType)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        guard value.null == nil else { throw SuiError.customError(message: "Invalid coin type") }
        return SuiCoinMetadata(
            decimals: value["decimals"].uInt8Value,
            description: value["description"].stringValue,
            iconUrl: value["iconUrl"].string,
            name: value["name"].stringValue,
            symbol: value["symbol"].stringValue,
            id: value["id"].stringValue
        )
    }

    /// Return all Coin<`coin_type`> objects owned by an address.
    /// - Parameters:
    ///   - account: The account whose coins are to be retrieved.
    ///   - coinType: Optional type name for the coin (e.g., 0x168da5bf1f48dafc111b0a488fa454aca95e0b5e::usdc::USDC), default to 0x2::sui::SUI if not specified.
    ///   - cursor: Optional. A cursor for pagination.
    ///   - limit: Optional. A limit on the number of coins to be retrieved.
    /// - Throws: `SuiError` if there is any error in the JSON RPC call or the response.
    /// - Returns: A `PaginatedCoins` object containing the retrieved coins and pagination information.
    public func getCoins(
        account: String,
        coinType: String? = nil,
        cursor: String? = nil,
        limit: UInt? = nil
    ) async throws -> PaginatedCoins {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getCoins",
                [
                    AnyCodable(account),
                    AnyCodable(coinType),
                    AnyCodable(cursor),
                    AnyCodable(limit)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        var coinPages: [CoinStruct] = []
        let result = try JSONDecoder().decode(JSON.self, from: data)["result"]
        for value in result["data"].arrayValue {
            coinPages.append(
                try CoinStruct(
                    coinType: value["coinType"].stringValue,
                    coinObjectId: value["coinObjectId"].stringValue,
                    version: value["version"].stringValue,
                    digest: value["digest"].stringValue,
                    balance: value["balance"].stringValue,
                    previousTransaction: value["previousTransaction"].stringValue
                )
            )
        }
        return PaginatedCoins(
            data: coinPages,
            nextCursor: result["nextCursor"].stringValue,
            hasNextPage: result["hasNextPage"].boolValue
        )
    }

    /// Return the committee information for the asked `epoch`.
    /// - Parameter epoch: he epoch of interest. If None, default to the latest epoch.
    /// - Returns: A `CommitteeInfo` object containing the information of the committee for the specified epoch.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getCommitteeInfo(
        epoch: String
    ) async throws -> CommitteeInfo {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getCommitteeInfo",
                [
                    AnyCodable(epoch)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        var validators: [[String]] = [[]]
        for validator in result["validators"].arrayValue {
            var innerValidators: [String] = []
            for innerValidator in validator.arrayValue {
                innerValidators.append(innerValidator.stringValue)
            }
            validators.append(innerValidators)
        }
        return CommitteeInfo(
            epoch: result["epoch"].stringValue,
            validators: validators
        )
    }

    /// Return the dynamic field object information for a specified object.
    /// - Parameters:
    ///   - parentId: The ID of the queried parent object.
    ///   - name: The Name of the dynamic field.
    /// - Returns: An optional `SuiObjectResponse` containing the information of the dynamic field object, `nil` if not found.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getDynamicFieldObject(
        parentId: String,
        name: String
    ) async throws -> SuiObjectResponse? {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getDynamicFieldObject",
                [
                    AnyCodable(parentId),
                    AnyCodable(name)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return SuiObjectResponse(input: result)
    }

    /// Return the dynamic field object information for a specified object.
    /// - Parameters:
    ///   - parentId: The ID of the queried parent object.
    ///   - name: The Name of the dynamic field.
    /// - Returns: An optional `SuiObjectResponse` containing the information of the dynamic field object, `nil` if not found.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getDynamicFieldObject(
        parentId: String,
        name: DynamicFieldName
    ) async throws -> SuiObjectResponse? {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getDynamicFieldObject",
                [
                    AnyCodable(parentId),
                    AnyCodable(name)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        return SuiObjectResponse(input: result)
    }

    /// Return the list of dynamic field objects owned by an object.
    /// - Parameters:
    ///   - parentId: The ID of the parent object.
    ///   - filter: An optional filter to apply to the dynamic fields.
    ///   - options: An optional set of options to apply to the dynamic fields.
    ///   - limit: Maximum item returned per page, default to [QUERY_MAX_RESULT_LIMIT] if not specified.
    ///   - cursor: An optional paging cursor. If provided, the query will start from the next item after the specified cursor. Default to start from the first item if not specified.
    /// - Returns: A `DynamicFieldPage` containing the paginated dynamic fields.
    /// - Throws: `SuiError.unableToValidateAddress` if the parent ID is not a valid Sui address.
    ///           `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getDynamicFields(
        parentId: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions? = nil,
        limit: Int? = nil,
        cursor: String? = nil
    ) async throws -> DynamicFieldPage {
        guard (try Inputs.normalizeSuiAddress(value: parentId)).isValidSuiAddress() else { throw SuiError.customError(message: "Unable to validate address") }
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getDynamicFields",
                [
                    AnyCodable(parentId),
                    AnyCodable(cursor),
                    AnyCodable(limit),
                    AnyCodable(filter),
                    AnyCodable(options)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        var dynamicFields: [DynamicFieldInfo] = []

        for fieldInfo in result["data"].arrayValue {
            dynamicFields.append(
                DynamicFieldInfo(
                    bcsName: fieldInfo["bcsName"].stringValue,
                    digest: fieldInfo["digest"].stringValue,
                    name: DynamicFieldName(
                        type: fieldInfo["name"]["type"].stringValue,
                        value: fieldInfo["name"]["value"]
                    ),
                    objectId: fieldInfo["objectId"].stringValue,
                    objectType: fieldInfo["objectType"].stringValue,
                    type: DynamicFieldType(rawValue: fieldInfo["type"].stringValue)!,
                    version: fieldInfo["version"].stringValue
                )
            )
        }
        return DynamicFieldPage(
            data: dynamicFields,
            nextCursor: result["nextCursor"].string,
            hasNextPage: result["hasNextPage"].boolValue
        )
    }

    /// Return the latest SUI system state object on-chain.
    /// - Returns: A `JSON` object containing the information of the latest Sui system state.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func info() async throws -> JSON {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getLatestSuiSystemState", [])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]
    }

    /// Return the latest SUI system state object on-chain.
    /// - Returns: A `JSON` object containing the information of the latest Sui system state.
    /// - Throws: `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getSuiSystemState() async throws -> JSON {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getLatestSuiSystemState", [])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]
    }

    /// Return the list of objects owned by an address.
    ///
    /// If the address owns more than `QUERY_MAX_RESULT_LIMIT` objects, the pagination is not accurate, because previous page may have been updated when the next page is fetched.
    /// Please use suix_queryObjects if this is a concern.
    /// - Parameters:
    ///   - owner: The identifier of the owner.
    ///   - filter: An optional filter to apply to the owned objects.
    ///   - options: An optional set of options to apply to the owned objects.
    ///   - cursor: An optional cursor for paginating through owned objects.
    ///   - limit: An optional limit to the number of owned objects returned.
    /// - Returns: A `PaginatedObjectsResponse` containing the paginated owned objects.
    /// - Throws: `SuiError.unableToValidateAddress` if the owner is not a valid Sui address.
    ///           `SuiError.rpcError` if there are errors in the JSON RPC response.
    public func getOwnedObjects(
        owner: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions? = nil,
        cursor: String? = nil,
        limit: Int? = nil
    ) async throws -> PaginatedObjectsResponse {
        guard owner.isValidSuiAddress() else { throw SuiError.customError(message: "Unable to validate address") }
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getOwnedObjects",
                [
                    AnyCodable(owner),
                    AnyCodable(
                        SuiObjectResponseQuery(
                            filter: filter,
                            options: options
                        )
                    ),
                    AnyCodable(cursor),
                    AnyCodable(limit)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)
        let objects: [SuiObjectResponse] = result["result"]["data"].arrayValue.compactMap {
            SuiObjectResponse(input: $0)
        }
        return PaginatedObjectsResponse(
            data: objects,
            hasNextPage: result["result"]["hasNextPage"].boolValue,
            nextCursor: result["result"]["nextCursor"].string
        )
    }

    /// Return the reference gas price for the network.
    /// - Returns: A UInt64 representing the reference gas price.
    /// - Throws: An error if the RPC request fails.
    public func getReferenceGasPrice() async throws -> BigInt {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getReferenceGasPrice", [])
        )
        return BigInt(JSON(data)["result"].stringValue, radix: 10)!
    }

    /// Retrieves the staking information for a given owner.
    /// - Parameter owner: The address of the owner whose staking information is to be retrieved.
    /// - Returns: An array of `DelegatedStake` objects representing the staking information.
    /// - Throws: An error if the RPC request fails or JSON parsing errors occur.
    public func getStakes(
        owner: String
    ) async throws -> [DelegatedStake] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getStakes",
                [
                    AnyCodable(owner)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        var stakes: [DelegatedStake] = []
        for value in result.arrayValue {
            let stakeJson = value["stakes"].arrayValue
            var stakesInner: [StakeStatus] = []
            for stakeInner in stakeJson {
                let finalStake = StakeObject(
                    principal: stakeInner["principal"].stringValue,
                    stakeActiveEpoch: stakeInner["stakeActiveEpoch"].stringValue,
                    stakeRequestEpoch: stakeInner["stakeRequestEpoch"].stringValue,
                    stakeSuiId: stakeInner["stakedSuiId"].stringValue
                )
                switch stakeInner["status"].stringValue {
                case "Active":
                    stakesInner.append(.active(finalStake))
                case "Pending":
                    stakesInner.append(.pending(finalStake))
                case "Unstaked":
                    stakesInner.append(.unstaked(finalStake))
                default:
                    throw SuiError.customError(message: "Unable to parse JSON")
                }
            }
            stakes.append(
                DelegatedStake(
                    stakes: stakesInner,
                    stakingPool: value["stakingPool"].stringValue,
                    validatorAddress: value["validatorAddress"].stringValue
                )
            )
        }
        return stakes
    }

    /// Retrieves the staking information for given stake IDs.
    ///
    /// If a Stake was withdrawn its status will be Unstaked.
    /// - Parameter stakes: An array of stake IDs whose staking information is to be retrieved.
    /// - Returns: An array of `DelegatedStake` objects representing the staking information.
    /// - Throws: An error if the RPC request fails or JSON parsing errors occur.
    public func getStakesByIds(
        stakes: [String]
    ) async throws -> [DelegatedStake] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getStakesByIds",
                [
                    AnyCodable(stakes)
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.customError(message: "RPC Error: \(errorValue.localizedDescription)") }
        let result = JSON(data)["result"]
        var stakes: [DelegatedStake] = []
        for value in result.arrayValue {
            let stakeJson = value["stakes"].arrayValue
            var stakesInner: [StakeStatus] = []
            for stakeInner in stakeJson {
                let finalStake = StakeObject(
                    principal: stakeInner["principal"].stringValue,
                    stakeActiveEpoch: stakeInner["stakeActiveEpoch"].stringValue,
                    stakeRequestEpoch: stakeInner["stakeRequestEpoch"].stringValue,
                    stakeSuiId: stakeInner["stakedSuiId"].stringValue
                )
                switch stakeInner["status"].stringValue {
                case "Active":
                    stakesInner.append(.active(finalStake))
                case "Pending":
                    stakesInner.append(.pending(finalStake))
                case "Unstaked":
                    stakesInner.append(.unstaked(finalStake))
                default:
                    throw SuiError.customError(message: "Unable to parse JSON")
                }
            }
            stakes.append(
                DelegatedStake(
                    stakes: stakesInner,
                    stakingPool: value["stakingPool"].stringValue,
                    validatorAddress: value["validatorAddress"].stringValue
                )
            )
        }
        return stakes
    }

    /// Retrieves the total supply of a coin type.
    /// - Parameter coinType: The type of the coin whose total supply is to be retrieved.
    /// - Returns: A UInt64 representing the total supply of the coin type.
    /// - Throws: An error if the RPC request fails.
    public func totalSupply(_ coinType: String) async throws -> BigInt {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getTotalSupply", [AnyCodable(coinType)])
        )
        let resultString = try JSONDecoder().decode(JSON.self, from: data)["result"]["value"].stringValue
        guard let result = BigInt(resultString, radix: 10) else { throw NSError(domain: "Unable to convert to BigInt", code: -1) }
        // return (BigInt(data.coinMetadata!.supply!, radix: 10)! * 10).power(data.coinMetadata!.decimals!)
        return result
    }

    /// Retrieves the annual percentage yield (APY) of validators.
    /// - Returns: A `ValidatorApys` object representing the APYs of validators.
    /// - Throws: An error if the RPC request fails.
    public func getValidatorsApy() async throws -> ValidatorApys {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getValidatorsApy", [])
        )
        let result = JSON(data)["result"]
        return ValidatorApys(input: result)
    }

    /// Queries events from the blockchain with provided filters.
    /// - Parameters:
    ///   - query: An optional `SuiEventFilter` to filter the events.
    ///   - cursor: An optional `EventId` to fetch events after a specific event ID.
    ///   - limit: An optional integer to limit the number of events fetched.
    ///   - order: An optional `SortOrder` enum to sort the fetched events.
    /// - Returns: A `PaginatedSuiMoveEvent` object representing the fetched events.
    /// - Throws: An error if the RPC request fails or the event parsing fails.
    public func queryEvents(
        query: SuiEventFilter? = nil,
        cursor: EventId? = nil,
        limit: Int? = nil,
        order: SortOrder? = nil
    ) async throws -> PaginatedSuiMoveEvent {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_queryEvents",
                [
                    AnyCodable(query == nil ? SuiEventFilter.all([]) : query),
                    AnyCodable(cursor),
                    AnyCodable(limit),
                    AnyCodable(order == .descending ? true : false)
                ]
            )
        )
        var eventPages: [SuiEvent] = []
        let result = JSON(data)["result"]
        for event in result["data"].arrayValue {
            guard let eventUnwrapped = SuiEvent(input: event) else { continue }
            eventPages.append(eventUnwrapped)
        }
        return PaginatedSuiMoveEvent(
            data: eventPages,
            nextCursor: EventId.parseJSON(result["nextCursor"]),
            hasNextPage: result["hasNextPage"].boolValue
        )
    }

    /// Queries transaction blocks based on provided parameters.
    /// - Parameters:
    ///   - cursor: An optional string used as a starting point to fetch transaction blocks.
    ///   - limit: An optional integer representing the maximum number of transaction blocks to fetch.
    ///   - order: An optional `SortOrder` enum to sort the fetched transaction blocks.
    ///   - filter: An optional `TransactionFilter` to filter the fetched transaction blocks.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to specify response options.
    /// - Returns: A `PaginatedTransactionResponse` object containing the transaction blocks that meet the given criteria.
    /// - Throws: An error if the RPC request fails or if the parsing of the received data fails.
    public func queryTransactionBlocks(
        cursor: String? = nil,
        limit: Int? = nil,
        order: SortOrder? = nil,
        filter: TransactionFilter? = nil,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> PaginatedTransactionResponse {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_queryTransactionBlocks",
                [
                    AnyCodable(
                        SuiTransactionBlockResponseQuery(
                            filter: filter,
                            options: options
                        )
                    ),
                    AnyCodable(cursor),
                    AnyCodable(limit),
                    AnyCodable(order == .descending ? true : false)
                ]
            )
        )
        var responsePage: [SuiTransactionBlockResponse] = []
        let result = JSON(data)["result"]
        for response in result["data"].arrayValue {
            let responseUnwrapped = SuiTransactionBlockResponse(input: response)
            responsePage.append(responseUnwrapped)
        }
        return PaginatedTransactionResponse(
            data: responsePage,
            hasNextPage: result["hasNextPage"].boolValue,
            nextCursor: result["nextCursor"].stringValue
        )
    }

    /// Resolves a nameservice address to its corresponding account address.
    /// - Parameter name: A string representing the nameservice address to resolve.
    /// - Returns: An `AccountAddress` representing the resolved account address.
    /// - Throws: An error if the RPC request fails or if the conversion from hexadecimal fails.
    public func resolveNameserviceAddress(name: String) async throws -> AccountAddress {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_resolveNameServiceAddress", [])
        )
        return try AccountAddress.fromHex(JSON(data)["result"].stringValue)
    }

    // TODO: Implement Resolve Name Service Names

    /// Waits for a transaction to be processed and retrieves the transaction block.
    /// - Parameters:
    ///   - tx: A string representing the transaction hash.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to specify response options.
    /// - Returns: A `SuiTransactionBlockResponse` object containing the information of the processed transaction block.
    /// - Throws: A `SuiError.transactionTimedOut` error if the transaction does not get processed within a certain time frame, or other errors if the RPC request fails.
    public func waitForTransaction(
        tx: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> SuiTransactionBlockResponse {
        let maxRetries = 30  // Reduced from 60
        var retryCount = 0
        var delay: UInt64 = 500_000_000  // Start with 0.5 seconds
        let maxDelay: UInt64 = 8_000_000_000  // Max 8 seconds

        repeat {
            if retryCount >= maxRetries {
                throw SuiError.customError(message: "Transaction timed out after \(maxRetries) attempts")
            }

            // Use exponential backoff with jitter to reduce server load
            if retryCount > 0 {
                let jitter = UInt64.random(in: 0...delay/4)  // Up to 25% jitter
                try await Task.sleep(nanoseconds: delay + jitter)
                delay = min(delay * 2, maxDelay)  // Exponential backoff, capped at maxDelay
            }

            retryCount += 1
        } while await !(self.isValidTransactionBlock(tx: tx, options: options))

        return try await self.getTransactionBlock(digest: tx, options: options)
    }

    /// Checks if a transaction block is valid by ensuring it has a timestamp.
    /// - Parameters:
    ///   - tx: A string representing the transaction hash.
    ///   - options: An optional `SuiTransactionBlockResponseOptions` to specify response options.
    /// - Returns: A Boolean indicating whether the transaction block is valid.
    private func isValidTransactionBlock(
        tx: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async -> Bool {
        do {
            let result = try await self.getTransactionBlock(digest: tx, options: options)
            return result.timestampMs != nil
        } catch {
            return false
        }
    }

    /// Parses and normalizes modules from the provided JSON result.
    /// - Parameter result: A JSON object containing the modules to be parsed.
    /// - Returns: A `SuiMoveNormalizedModules` object containing the parsed modules.
    /// - Throws: An error if the parsing fails.
    private func parseNormalizedModules(result: JSON) throws -> SuiMoveNormalizedModules {
        var modules: SuiMoveNormalizedModules = [:]
        for (key, value) in result.dictionaryValue {
            modules[key] = SuiMoveNormalizedModule(input: value)
        }
        return modules
    }

    private func hasErrors(_ data: JSON) -> RPCErrorValue {
        if data["error"].exists() {
            return RPCErrorValue(
                id: data["id"].intValue,
                error: ErrorMessage(
                    message: data["error"]["message"].stringValue,
                    code: data["error"]["code"].intValue
                ),
                jsonrpc: data["jsonrpc"].stringValue,
                hasError: true
            )
        }
        return RPCErrorValue(id: nil, error: nil, jsonrpc: nil, hasError: false)
    }

    private func isValidTransactionDigest(_ value: String) -> Bool {
        guard !value.isEmpty else { return false }
        guard let buffer = value.base58DecodedData else { return false }
        return buffer.count == 32
    }

    private func getServerUrl() throws -> URL {
        guard let url = URL(string: self.connection.fullNode) else {
            throw SuiError.customError(message: "Invalid URL: \(self.connection.fullNode)")
        }
        return url
    }

    /// Get epoch information required for zkLogin
    /// - Returns: Current epoch information from the network
    public func getzkLoginEpochInfo() async throws -> EpochInfo {
        let systemState = try await getSuiSystemState()

        return EpochInfo(
            epoch: systemState["epoch"].uInt64Value,
            epochStartTimestampMs: systemState["epochStartTimestampMs"].uInt64Value,
            epochDurationMs: systemState["epochDurationMs"].uInt64Value
        )
    }
}
