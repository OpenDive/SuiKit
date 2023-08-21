//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation
import SwiftyJSON
import AnyCodable
import Blake2
import Base58Swift

public struct SuiProvider {
    public var connection: any ConnectionProtcol

    public init(connection: any ConnectionProtcol) {
        self.connection = connection
    }

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
//        print("DEBUG: TX BLOCK DEV INSPECT - \([UInt8](result))")
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return DevInspectResults(input: JSON(data)["result"])
    }

    public func dryRunTransactionBlock(
        transactionBlock: [UInt8]
    ) async throws -> SuiTransactionBlockResponse {
//        print("DEBUG: DRY RUN BYTES - \(transactionBlock)")
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
//        print("DEBUG: DRY RUN TX RESULT - \(JSON(data)["result"])")
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    public func executeTransactionBlock(
        transactionBlock: [UInt8],
        signature: String,
        options: SuiTransactionBlockResponseOptions? = nil,
        requestType: SuiRequestType? = nil
    ) async throws -> SuiTransactionBlockResponse {
//        print("DEBUG: TRANSACTION BLOCK BYTES - \(transactionBlock)")
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
//        print("DEBUG: RESULT - \(JSON(data))")
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    public func getChainIdentifier() async throws -> String {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getChainIdentifier",
                []
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return JSON(data)["result"].stringValue
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let value = JSON(data)["result"]
        return Checkpoint(input: value)
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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

    public func getLatestCheckpointSequenceNumber() async throws -> String {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getLatestCheckpointSequenceNumber", [])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return JSON(data)["result"].stringValue
    }

    public func getLoadedChildObjects(
        digest: String
    ) async throws -> [TransactionEffectsModifiedAtVersions] {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getLoadedChildObjects", [AnyCodable(digest)])
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return result.arrayValue.map { TransactionEffectsModifiedAtVersions(input: $0) }
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return SuiMoveNormalizedFunction(input: result)
    }

    public func getNormalizedModuleModule(
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return SuiMoveNormalizedModule(input: result)
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return try self.parseNormalizedModules(result: result)
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return SuiMoveNormalizedStruct(input: result)
    }

    public func getObject(
        objectId: String,
        options: SuiObjectDataOptions? = nil
    ) async throws -> SuiObjectResponse? {
        guard (try Inputs.normalizeSuiAddress(value: objectId)).isValidSuiAddress() else { throw SuiError.unableToValidateAddress }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let value = JSON(data)["result"]
        return SuiObjectResponse(input: value)
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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

    public func getTotalTransactionBlocks() async throws -> UInt64 {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getTotalTransactionBlocks", [])
        )
        return JSON(data)["result"].uInt64Value
    }

    public func getTransactionBlock(
        digest: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> SuiTransactionBlockResponse {
        guard self.isValidTransactionDigest(digest) else { throw SuiError.invalidDigest }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return SuiTransactionBlockResponse(input: JSON(data)["result"])
    }

    public func getMultiObjects(
        ids: [objectId],
        options: SuiObjectDataOptions? = nil
    ) async throws -> [SuiObjectResponse] {
        for object in ids {
            guard (try Inputs.normalizeSuiAddress(value: object)).isValidSuiAddress() else {
                throw SuiError.unableToValidateAddress
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let jsonResponse = JSON(data)["result"]
        var objectResponses: [SuiObjectResponse] = []
        for jsonData in jsonResponse.arrayValue {
            guard let object = SuiObjectResponse(input: jsonData) else { continue }
            objectResponses.append(object)
        }
        return objectResponses
    }

    public func multiGetTransactionBlocks(
        digests: [String],
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> [SuiTransactionBlockResponse] {
        for digest in digests {
            guard self.isValidTransactionDigest(digest) else { throw SuiError.invalidDigest }
        }
        guard digests.count == Set(digests).count else { throw SuiError.digestsDoNotMatch }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return JSON(data)["result"].arrayValue.map { SuiTransactionBlockResponse(input: $0) }
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return ObjectRead.parseJSON(result)
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return result.arrayValue.compactMap { ObjectRead.parseJSON($0) }
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        var balances: [CoinBalance] = []
        for (_, value):(String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"] {
            let lockedBalance = value["lockedBalance"]
            balances.append(
                CoinBalance(
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        var coinPages: [CoinStruct] = []
        let result = try JSONDecoder().decode(JSON.self, from: data)["result"]
        for (_, value):(String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"]["data"] {
            coinPages.append(
                CoinStruct(
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        let lockedBalance = value["lockedBalance"]
        return CoinBalance(
            coinType: value["coinType"].stringValue,
            coinObjectCount: value["coinObjectCount"].intValue,
            totalBalance: value["totalBalance"].stringValue,
            lockedBalance: value["lockedBalance"].isEmpty ? nil : LockedBalance(
                epochId: lockedBalance["epochId"].intValue,
                number: lockedBalance["number"].intValue
            )
        )
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        guard value.null == nil else { throw SuiError.invalidCoinType }
        return SuiCoinMetadata(
            decimals: value["decimals"].uInt8Value,
            description: value["description"].stringValue,
            iconUrl: value["iconUrl"].string,
            name: value["name"].stringValue,
            symbol: value["symbol"].stringValue,
            id: value["id"].stringValue
        )
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        var coinPages: [CoinStruct] = []
        let result = try JSONDecoder().decode(JSON.self, from: data)["result"]
        for (_, value): (String, JSON) in result["data"] {
            coinPages.append(
                CoinStruct(
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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
                    AnyCodable(name),
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return SuiObjectResponse(input: result)
    }

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
                    AnyCodable(name),
                ]
            )
        )
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        return SuiObjectResponse(input: result)
    }

    public func getDynamicFields(
        parentId: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions? = nil,
        limit: Int? = nil,
        cursor: String? = nil
    ) async throws -> DynamicFieldPage {
        guard (try Inputs.normalizeSuiAddress(value: parentId)).isValidSuiAddress() else { throw SuiError.unableToValidateAddress }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)["result"]
        var dynamicFields: [DynamicFieldInfo] = []

        for fieldInfo in result["data"].arrayValue {
            dynamicFields.append(
                DynamicFieldInfo(
                    bcsName: fieldInfo["bcsName"].stringValue,
                    digest: fieldInfo["digest"].stringValue,
                    name: DynamicFieldName(
                        type: fieldInfo["name"]["type"].stringValue,
                        value: fieldInfo["name"]["value"].stringValue
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

    public func info() async throws -> JSON {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getLatestSuiSystemState", [])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]
    }

    public func getOwnedObjects(
        owner: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions? = nil,
        cursor: String? = nil,
        limit: Int? = nil
    ) async throws -> PaginatedObjectsResponse {
        guard owner.isValidSuiAddress() else { throw SuiError.unableToValidateAddress }
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let result = JSON(data)
        let objects: [SuiObjectResponse] = result["result"]["data"].arrayValue.compactMap {
            SuiObjectResponse(input: $0)
        }
        return PaginatedObjectsResponse(
            data: objects,
            hasNextPage: result["hasNextPage"].boolValue,
            nextCursor: result["nextCursor"].string
        )
    }

    public func getGasPrice() async throws -> UInt64 {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getReferenceGasPrice", [])
        )
        return JSON(data)["result"].uInt64Value
    }

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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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
                    throw SuiError.unableToParseJson
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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
                    throw SuiError.unableToParseJson
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

    public func totalSupply(_ coinType: String) async throws -> UInt64 {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getTotalSupply", [AnyCodable(coinType)])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]["value"].uInt64Value
    }

    public func getValidatorsApy() async throws -> ValidatorApys {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getValidatorsApy", [])
        )
        let result = JSON(data)["reslt"]
        return ValidatorApys(input: result)
    }

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

    public func resolveNameserviceAddress(name: String) async throws -> AccountAddress {
        let data = try await JsonRpcClient.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_resolveNameServiceAddress", [])
        )
        return try AccountAddress.fromHex(JSON(data)["result"].stringValue)
    }

    // TODO: Implement Resolve Name Service Names

    public func waitForTransaction(
        tx: String,
        options: SuiTransactionBlockResponseOptions? = nil
    ) async throws -> SuiTransactionBlockResponse {
        var count = 0
        repeat {
            if count >= 60 {
                throw SuiError.transactionTimedOut
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
            count += 1
        } while await !(self.isValidTransactionBlock(tx: tx, options: options))
        return try await self.getTransactionBlock(digest: tx, options: options)
    }

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
        guard let buffer = Base58.base58Decode(value) else { return false }
        return buffer.count == 32
    }

    private func getServerUrl() throws -> URL {
        guard let url = URL(string: self.connection.fullNode) else {
            throw SuiError.invalidUrl(url: self.connection.fullNode)
        }
        return url
    }
}
