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

public struct SuiProvider {
    public var connection: any ConnectionProtcol
    
    public init(connection: any ConnectionProtcol) {
        self.connection = connection
    }
    
    public func info() async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getLatestSuiSystemState", [])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]
    }
    
    public func getGasPrice() async throws -> UInt64 {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getReferenceGasPrice", [])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"].uInt64Value
    }
    
    public func totalSupply(_ coinType: String) async throws -> UInt64 {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getTotalSupply", [AnyCodable(coinType)])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]["value"].uInt64Value
    }
    
    public func getAllBalances(_ account: Account) async throws -> [CoinBalance] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllBalances", [
                AnyCodable(try account.publicKey.toSuiAddress())
            ])
        )
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
    
    public func getBalance(_ account: Account, _ coinType: String) async throws -> CoinBalance {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getBalance", [
                AnyCodable(try account.publicKey.toSuiAddress()),
                AnyCodable(coinType)
            ])
        )
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
    
    public func getAllCoins(_ account: any PublicKeyProtocol, _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> PaginatedCoins {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllCoins", [
                AnyCodable(try account.toSuiAddress()),
                AnyCodable(cursor),
                AnyCodable(limit)
            ])
        )
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
    
    public func getCoins(_ account: any PublicKeyProtocol, _ coinType: String, _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> PaginatedCoins {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getCoins",
                [
                    AnyCodable(try account.toSuiAddress()),
                    AnyCodable(coinType),
                    AnyCodable(cursor),
                    AnyCodable(limit)
                ]
            )
        )
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
    
    public func getCoinMetadata(_ coinType: String) async throws -> SuiCoinMetadata {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getCoinMetadata",
                [
                    AnyCodable(coinType)
                ]
            )
        )
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
    
    public func getEvents(_ transactionDigest: String) async throws -> PaginatedSuiMoveEvent {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getEvents",
                [
                    AnyCodable(transactionDigest)
                ]
            )
        )
        var eventPages: [SuiMoveEvent] = []
        let result = try JSONDecoder().decode(JSON.self, from: data)["result"]
        for (_, value): (String, JSON) in result["data"] {
            let cursor = value["id"]
            eventPages.append(
                SuiMoveEvent(
                    bcs: value["bcs"].stringValue,
                    parsedJson: value["parsedJson"].dictionaryValue,
                    packageId: value["packageId"].stringValue,
                    sender: value["sender"].stringValue,
                    transactionModule: value["transactionModule"].stringValue,
                    type: value["type"].stringValue,
                    id: Cursor(
                        txDigest: cursor["txDigest"].stringValue,
                        eventSeq: cursor["eventSeq"].stringValue
                    )
                )
            )
        }
        let cursor = result["nextCursor"]
        return PaginatedSuiMoveEvent(
            data: eventPages,
            nextCursor: Cursor(
                txDigest: cursor["txDigest"].stringValue,
                eventSeq: cursor["eventSeq"].stringValue
            ),
            hasNextPage: result["hasNextPage"].boolValue
        )
    }
    
    public func getCheckpoint(_ id: String) async throws -> Checkpoint {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getCheckpoint",
                [
                    AnyCodable(id)
                ]
            )
        )
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        let epochRollingGasCostSummary = value["epochRollingGasCostSummary"]
        let gasCostSummary = GasCostSummary(
            computationCost: epochRollingGasCostSummary["computationCost"].stringValue,
            storageCost: epochRollingGasCostSummary["storageCost"].stringValue,
            storageRebate: epochRollingGasCostSummary["storageRebate"].stringValue,
            nonRefundableStorageFee: epochRollingGasCostSummary["nonRefundableStorageFee"].stringValue
        )
        
        return Checkpoint(
            epoch: value["epoch"].stringValue,
            sequenceNumber: value["sequenceNumber"].stringValue,
            digest: value["digest"].stringValue,
            networkTotalTransactions: value["networkTotalTransactions"].stringValue,
            previousDigest: value["previousDigest"].string,
            epochRollingGasCostSummary: gasCostSummary,
            timestampMs: value["timestampMs"].stringValue,
            validatorSignature: value["validatorSignature"].stringValue,
            transactions: value["transactions"].arrayValue.map { $0.stringValue },
            checkpointComitments: value["transactions"].arrayValue.map { $0.rawValue }
        )
    }
    
    public func getCheckpoints(_ cursor: String? = nil, _ limit: Int? = nil, _ descendingOrder: Bool = false) async throws -> CheckpointPage {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getCheckpoints",
                [
                    AnyCodable(cursor),
                    AnyCodable(limit),
                    AnyCodable(descendingOrder)
                ]
            )
        )
        var checkpointPages: [Checkpoint] = []
        let result = try JSONDecoder().decode(JSON.self, from: data)["result"]
        for (_, value): (String, JSON) in result["data"] {
            let epochRollingGasCostSummary = value["epochRollingGasCostSummary"]
            let gasCostSummary = GasCostSummary(
                computationCost: epochRollingGasCostSummary["computationCost"].stringValue,
                storageCost: epochRollingGasCostSummary["storageCost"].stringValue,
                storageRebate: epochRollingGasCostSummary["storageRebate"].stringValue,
                nonRefundableStorageFee: epochRollingGasCostSummary["nonRefundableStorageFee"].stringValue
            )
            
            checkpointPages.append(
                Checkpoint(
                    epoch: value["epoch"].stringValue,
                    sequenceNumber: value["sequenceNumber"].stringValue,
                    digest: value["digest"].stringValue,
                    networkTotalTransactions: value["networkTotalTransactions"].stringValue,
                    previousDigest: value["previousDigest"].string,
                    epochRollingGasCostSummary: gasCostSummary,
                    timestampMs: value["timestampMs"].stringValue,
                    validatorSignature: value["validatorSignature"].stringValue,
                    transactions: value["transactions"].arrayValue.map { $0.stringValue },
                    checkpointComitments: value["transactions"].arrayValue.map { $0.rawValue }
                )
            )
        }
        return CheckpointPage(
            data: checkpointPages,
            nextCursor: result["nextCursor"].stringValue,
            hasNextPage: result["hasNextPage"].boolValue
        )
    }
    
    public func getObject(_ objectId: String, _ options: GetObject = GetObject()) async throws -> SuiObjectResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getObject",
                [
                    AnyCodable(objectId),
                    AnyCodable(options)
                ]
            )
        )
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        guard let fields = value["content"]["fields"].dictionaryObject else { throw NSError(domain: "Unable to unwrap fields.", code: -1) }
        return SuiObjectResponse(
            objectId: value["objectId"].stringValue,
            version: value["version"].uInt64Value,
            digest: value["digest"].stringValue,
            type: value["type"].stringValue,
            owner: ObjectOwner(
                addressOwner: AddressOwner(addressOwner: value["owner"]["AddressOwner"].stringValue),
                objectOwner: ObjectOwnerAddress(objectOwner: value["owner"]["ObjectOwner"].stringValue),
                shared: Shared(
                    shared: InitialSharedVersion(initialSharedVersion: value["owner"]["Shared"]["InitialSharedVersion"].intValue)
                )
            ),
            previousTransaction: value["previousTransaction"].stringValue,
            storageRebate: value["storageRebate"].intValue,
            content: SuiMoveObject(
                type: value["content"]["type"].stringValue,
                fields: fields,
                hasPublicTransfer: value["content"]["hasPublicTransfer"].boolValue
            )
        )
    }
    
    public func getOwnedObjects(_ account: any PublicKeyProtocol, _ query: GetOwnedObjects = GetOwnedObjects(), _ cursor: String? = nil, _ limit: Int? = nil) async throws -> [SuiObjectResponse] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getOwnedObjects",
                [
                    AnyCodable(try account.toSuiAddress()),
                    AnyCodable(query),
                    AnyCodable(cursor),
                    AnyCodable(limit)
                ]
            )
        )
        var result: [SuiObjectResponse] = []
        for (_, val):(String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"]["data"] {
            let value = val["data"]
            guard let fields = value["content"]["fields"].dictionaryObject else { throw NSError(domain: "Unable to unwrap fields", code: -1) }
            result.append(
                SuiObjectResponse(
                    objectId: value["objectId"].stringValue,
                    version: value["version"].uInt64Value,
                    digest: value["digest"].stringValue,
                    type: value["type"].stringValue,
                    owner: ObjectOwner(
                        addressOwner: AddressOwner(addressOwner: value["owner"]["AddressOwner"].stringValue),
                        objectOwner: ObjectOwnerAddress(objectOwner: value["owner"]["ObjectOwner"].stringValue),
                        shared: Shared(
                            shared: InitialSharedVersion(initialSharedVersion: value["owner"]["Shared"]["InitialSharedVersion"].intValue)
                        )
                    ),
                    previousTransaction: value["previousTransaction"].stringValue,
                    storageRebate: value["storageRebate"].intValue,
                    content: SuiMoveObject(
                        type: value["content"]["type"].stringValue,
                        fields: fields,
                        hasPublicTransfer: value["content"]["hasPublicTransfer"].boolValue
                    )
                )
            )
        }
        return result
    }
    
    public func requestAddStake(_ signer: Account, _ coins: [String], _ amount: String, _ validators: SuiAddress, _ gas: objectId, _ gasBudget: String) async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_requestAddStake",
                [
                    AnyCodable(try signer.publicKey.toSuiAddress()),
                    AnyCodable(coins),
                    AnyCodable(amount),
                    AnyCodable(validators),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return JSON(data)["result"]
    }
    
    public func requestWithdrawStake(_ signer: Account, _ stakedSui: objectId, _ gas: objectId, _ gasBudget: String) async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_requestWithdrawStake",
                [
                    AnyCodable(try signer.publicKey.toSuiAddress()),
                    AnyCodable(stakedSui),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return JSON(data)["result"]
    }
    
    public func getNormalizedMoveModulesByPackage(_ package: String) async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getNormalizedMoveModulesByPackage",
                [
                    AnyCodable(package)
                ]
            )
        )

        return JSON(data)["result"]
    }
    
    // TODO: Finish getNormalizedMoveStruct
    
    // TODO: Finish getNormalizedMoveModule
    
    public func getMultiObjects(_ ids: [objectId], _ options: GetObject?) async throws -> [SuiObjectResponse] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_multiGetObjects",
                [
                    AnyCodable(ids),
                    AnyCodable(options)
                ]
            )
        )
        
        let jsonResponse = JSON(data)["result"]
        var objectResponses: [SuiObjectResponse] = []
        
        try jsonResponse.arrayValue.forEach { jsonData in
            let value = jsonData["data"]
            guard let fields = value["content"]["fields"].dictionaryObject else { throw NSError(domain: "Unable to unwrap fields.", code: -1) }
            
            objectResponses.append(
                SuiObjectResponse(
                    objectId: value["objectId"].stringValue,
                    version: value["version"].uInt64Value,
                    digest: value["digest"].stringValue,
                    type: value["type"].stringValue,
                    owner: ObjectOwner(
                        addressOwner: AddressOwner(addressOwner: value["owner"]["AddressOwner"].stringValue),
                        objectOwner: ObjectOwnerAddress(objectOwner: value["owner"]["ObjectOwner"].stringValue),
                        shared: Shared(
                            shared: InitialSharedVersion(initialSharedVersion: value["owner"]["Shared"]["InitialSharedVersion"].intValue)
                        )
                    ),
                    previousTransaction: value["previousTransaction"].stringValue,
                    storageRebate: value["storageRebate"].intValue,
                    content: SuiMoveObject(
                        type: value["content"]["type"].stringValue,
                        fields: fields,
                        hasPublicTransfer: value["content"]["hasPublicTransfer"].boolValue
                    )
                )
            )
        }
        
        return objectResponses
    }

    public func dryRunTransactionBlock(_ transactionBlock: [UInt8]) async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
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
        return JSON(data)["result"]
    }

    public func getNormalizedMoveFunction(
        _ package: String,
        _ moduleName: String,
        _ functionName: String
    ) async throws -> SuiMoveNormalizedFunction {
        let data = try await self.sendSuiJsonRpc(
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
        
        let result = JSON(data)["result"]
        
        return SuiMoveNormalizedFunction(
            visibility: try SuiMoveVisibility.decodeVisibility(result["visibility"]),
            isEntry: result["isEntry"].boolValue,
            typeParameters: result["typeParameters"].arrayValue.map {
                SuiMoveAbilitySet(abilities: $0["abilities"].arrayValue.map { $0.stringValue })
            },
            parameters: try result["parameters"].arrayValue.map {
                try SuiMoveNormalizedType.decodeNormalizedType($0)
            },
            returnValues: try result["return"].arrayValue.map {
                try SuiMoveNormalizedType.decodeNormalizedType($0)
            }
        )
    }
    
    // TODO: Finish getMoveFunctionArgTypes
    
    public func executeTransactionBlock(
        _ transactionBlock: String,
        _ signature: String,
        _ options: SuiTransactionBlockResponseOptions? = nil,
        _ requestType: SuiRequestType? = nil
    ) async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
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

        return JSON(data)["result"]
    }
    
    public func getProtocolConfig(_ version: String? = nil) async throws -> ProtocolConfig {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_getProtocolConfig",
                [
                    AnyCodable(version)
                ]
            )
        )
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
    
    public func devInspectTransactionBlock(
        _ transactionBlock: inout TransactionBlock,
        _ sender: SuiAddress,
        _ gasPrice: Int?,
        _ epoch: String?
    ) async throws -> JSON {
        transactionBlock.setSenderIfNotSet(sender: sender)
        let devInspectTxBytes = try await transactionBlock.build(self, true).base64EncodedString()
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_devInspectTransactionBlock",
                [
                    AnyCodable(sender),
                    AnyCodable(devInspectTxBytes),
                    AnyCodable(gasPrice),
                    AnyCodable(epoch)
                ]
            )
        )
        
        return JSON(data)["result"]
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
    
    private func getServerUrl() throws -> URL {
        guard let url = URL(string: self.connection.fullNode) else {
            throw SuiError.invalidUrl(url: self.connection.fullNode)
        }
        return url
    }
    
    private func processSuiJsonRpc(_ url: URL, _ request: SuiRequest) async throws -> SuiResponse {
        let data = try await sendSuiJsonRpc(url, request)
        
        do {
            return try JSONDecoder().decode(SuiResponse.self, from: data)
        } catch {
            let error = try JSONDecoder().decode(SuiClientError.self, from: data)
            throw error
        }
    }
    
    private func sendSuiJsonRpc(_ url: URL, _ request: SuiRequest) async throws -> Data {
        var requestUrl = URLRequest(url: url)
        requestUrl.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        requestUrl.httpMethod = "POST"
        
        do {
            let requestData = try JSONEncoder().encode(request)
            requestUrl.httpBody = requestData
        } catch {
            throw SuiError.encodingError
        }
        
        return try await withCheckedThrowingContinuation { (con: CheckedContinuation<Data, Error>) in
            let task = URLSession.shared.dataTask(with: requestUrl) { data, _, error in
                if let error = error {
                    con.resume(throwing: error)
                } else if let data = data {
                    con.resume(returning: data)
                } else {
                    con.resume(returning: Data())
                }
            }

            task.resume()
        }
    }
}

public struct ErrorMessage: Equatable {
    public let message: String
    public let code: Int
}

public struct RPCErrorValue: Equatable {
    public let id: Int?
    public let error: ErrorMessage?
    public let jsonrpc: String?
    public let hasError: Bool
}
