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
    
    public func getBalance(_ account: Account, _ coinType: String? = nil) async throws -> CoinBalance {
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

    public func getLatestCheckpointSequenceNumber() async throws -> String {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("sui_getLatestCheckpointSequenceNumber", [])
        )
        return JSON(data)["result"].stringValue
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
    
    public func getCoins(
        _ account: any PublicKeyProtocol,
        _ coinType: String? = nil,
        _ cursor: String? = nil,
        _ limit: UInt? = nil
    ) async throws -> PaginatedCoins {
        return try await self.getCoins(try account.toSuiAddress(), coinType, cursor, limit)
    }
    
    public func getCoins(_ account: String, _ coinType: String? = nil, _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> PaginatedCoins {
        let data = try await self.sendSuiJsonRpc(
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
        let gasCostSummary = GasCostSummaryCheckpoint(
            computationCost: epochRollingGasCostSummary["computationCost"].string,
            storageCost: epochRollingGasCostSummary["storageCost"].string,
            storageRebate: epochRollingGasCostSummary["storageRebate"].string,
            nonRefundableStorageFee: epochRollingGasCostSummary["nonRefundableStorageFee"].string
        )
        
        return Checkpoint(
            epoch: value["epoch"].string,
            sequenceNumber: value["sequenceNumber"].string,
            digest: value["digest"].stringValue,
            networkTotalTransactions: value["networkTotalTransactions"].string,
            previousDigest: value["previousDigest"].string,
            epochRollingGasCostSummary: gasCostSummary.computationCost == nil ? nil : gasCostSummary,
            timestampMs: value["timestampMs"].string,
            validatorSignature: value["validatorSignature"].stringValue,
            transactions: value["transactions"].arrayValue.map { $0.stringValue }
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
            let gasCostSummary = GasCostSummaryCheckpoint(
                computationCost: epochRollingGasCostSummary["computationCost"].string,
                storageCost: epochRollingGasCostSummary["storageCost"].string,
                storageRebate: epochRollingGasCostSummary["storageRebate"].string,
                nonRefundableStorageFee: epochRollingGasCostSummary["nonRefundableStorageFee"].string
            )
            
            checkpointPages.append(
                Checkpoint(
                    epoch: value["epoch"].string,
                    sequenceNumber: value["sequenceNumber"].string,
                    digest: value["digest"].stringValue,
                    networkTotalTransactions: value["networkTotalTransactions"].string,
                    previousDigest: value["previousDigest"].string,
                    epochRollingGasCostSummary: gasCostSummary,
                    timestampMs: value["timestampMs"].string,
                    validatorSignature: value["validatorSignature"].stringValue,
                    transactions: value["transactions"].arrayValue.map { $0.stringValue }
                )
            )
        }
        return CheckpointPage(
            data: checkpointPages,
            nextCursor: result["nextCursor"].stringValue,
            hasNextPage: result["hasNextPage"].boolValue
        )
    }
    
    public func getObject(_ objectId: String, _ options: SuiObjectDataOptions? = nil) async throws -> SuiObjectResponse {
        guard isValidSuiAddress(try normalizeSuiAddress(value: objectId)) else { throw SuiError.notImplemented }
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
        let value = JSON(data)["result"]
        return try self.parseObject(input: value)
    }
    
    public func getOwnedObjects(_ owner: String, _ filter: SuiObjectDataFilter? = nil, _ options: SuiObjectDataOptions? = nil, _ cursor: String? = nil, _ limit: Int? = nil) async throws -> PaginatedObjectsResponse {
        guard isValidSuiAddress(owner) else { throw SuiError.notImplemented }
        let data = try await self.sendSuiJsonRpc(
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
        let objects: [SuiObjectResponse] = try result["result"]["data"].arrayValue.map {
            try self.parseObject(input: $0)
        }
        return PaginatedObjectsResponse(
            data: objects,
            hasNextPage: result["hasNextPage"].boolValue,
            nextCursor: result["nextCursor"].string
        )
    }

    public func tryGetPastObject(id: String, version: Int, options: SuiObjectDataOptions? = nil) async throws -> ObjectRead? {
        let data = try await self.sendSuiJsonRpc(
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
        return self.parseObjectRead(result)
    }

    public func getDynamicFields(_ parentId: String, _ filter: SuiObjectDataFilter? = nil, _ options: SuiObjectDataOptions? = nil, _ limit: Int? = nil, _ cursor: String? = nil) async throws -> DynamicFieldPage {
        guard isValidSuiAddress(try normalizeSuiAddress(value: parentId)) else { throw SuiError.notImplemented }
        let data = try await self.sendSuiJsonRpc(
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

    public func getDynamicFieldObject(_ parentId: String, _ name: String) async throws -> SuiObjectResponse {
        let data = try await self.sendSuiJsonRpc(
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
        return try self.parseObject(input: result)
    }

    public func getDynamicFieldObject(_ parentId: String, name: DynamicFieldName) async throws -> SuiObjectResponse {
        let data = try await self.sendSuiJsonRpc(
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
        return try self.parseObject(input: result)
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
    
    public func getNormalizedMoveModulesByPackage(_ package: String) async throws -> SuiMoveNormalizedModules {
        let data = try await self.sendSuiJsonRpc(
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

    public func getNormalizedMoveStruct(package: String, module: String, structure: String) async throws -> SuiMoveNormalizedStruct {
        let data = try await self.sendSuiJsonRpc(
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
        return try self.parseNormalizedStruct(input: result)
    }

    public func getNormalizedModuleModule(package: String, module: String) async throws -> SuiMoveNormalizedModule {
        let data = try await self.sendSuiJsonRpc(
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
        return try self.parseNormalizedModule(input: result)
    }
    
    public func getMultiObjects(_ ids: [objectId], _ options: SuiObjectDataOptions? = nil) async throws -> [SuiObjectResponse] {
        for object in ids { guard isValidSuiAddress(try normalizeSuiAddress(value: object)) else { throw SuiError.notImplemented } }
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
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        let jsonResponse = JSON(data)["result"]
        var objectResponses: [SuiObjectResponse] = []
        try jsonResponse.arrayValue.forEach { jsonData in
            objectResponses.append(try self.parseObject(input: jsonData))
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

    public func getStakes(_ owner: String) async throws -> [DelegatedStake] {
        let data = try await self.sendSuiJsonRpc(
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
                    throw SuiError.notImplemented
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

    public func getStakesByIds(_ stakes: [String]) async throws -> [DelegatedStake] {
        let data = try await self.sendSuiJsonRpc(
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
                    throw SuiError.notImplemented
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

    public func getCommitteeInfo(_ epoch: String) async throws -> CommitteeInfo {
        let data = try await self.sendSuiJsonRpc(
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
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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

    public func getMoveFunctionArgTypes(package: String, module: String, function: String) async throws -> [SuiMoveFunctionArgType] {
        let data = try await self.sendSuiJsonRpc(
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
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return JSON(data)["result"]
    }

    public func executeTransactionBlock(
        _ transactionBlock: [UInt8],
        _ signature: String,
        _ options: SuiTransactionBlockResponseOptions? = nil,
        _ requestType: SuiRequestType? = nil
    ) async throws -> JSON {
        let data = try await self.sendSuiJsonRpc(
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
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
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
        _ gasPrice: Int? = nil,
        _ epoch: String? = nil
    ) async throws -> JSON {
        transactionBlock.setSenderIfNotSet(sender: sender)
        let result = try await transactionBlock.build(self, true)
        let devInspectTxBytes = result.base64EncodedString()
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
        let errorValue = self.hasErrors(JSON(data))
        guard !(errorValue.hasError) else { throw SuiError.rpcError(error: errorValue) }
        return JSON(data)["result"]
    }

    public func signAndExecuteTransactionBlock(
        _ transactionBlock: inout TransactionBlock,
        _ signer: Account,
        _ options: SuiTransactionBlockResponseOptions? = nil,
        _ requestType: SuiRequestType? = nil
    ) async throws -> JSON {
        transactionBlock.setSenderIfNotSet(sender: try signer.publicKey.toSuiAddress())
        let txBytes = try await transactionBlock.build(self)
        let signature = try signer.signTransactionBlock([UInt8](txBytes))
        return try await self.executeTransactionBlock(
            [UInt8](txBytes),
            try signer.toSerializedSignature(signature),
            options,
            requestType
        )
    }

    public func getTransactionBlock(_ digest: String, _ options: SuiTransactionBlockResponseOptions? = nil) async throws -> JSON {
        guard self.isValidTransactionDigest(digest) else { throw SuiError.notImplemented }
        let data = try await self.sendSuiJsonRpc(
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
        return JSON(data)["result"]
    }

    public func multiGetTransactionBlocks(_ digests: [String], _ options: SuiTransactionBlockResponseOptions? = nil) async throws -> [JSON] {
        for digest in digests {
            guard self.isValidTransactionDigest(digest) else { throw SuiError.notImplemented }
        }
        guard digests.count == Set(digests).count else { throw SuiError.notImplemented }
        let data = try await self.sendSuiJsonRpc(
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
        return JSON(data)["result"].arrayValue
    }

    public func waitForTransaction(_ tx: String) async throws {
        var count = 0

        repeat {
            if count >= 60 {
                throw SuiError.notImplemented
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
            count += 1
        } while await self.isValidTransactionBlock(tx)
    }

    private func isValidTransactionBlock(_ digest: String) async -> Bool {
        do {
            let result = try await self.getTransactionBlock(digest)
            return result["effects"]["status"]["status"].stringValue == "success"
        } catch {
            return false
        }
    }

    private func parseNormalizedModules(result: JSON) throws -> SuiMoveNormalizedModules {
        var modules: SuiMoveNormalizedModules = [:]
        for (key, value) in result.dictionaryValue {
            modules[key] = try self.parseNormalizedModule(input: value)
        }
        return modules
    }

    private func parseNormalizedStruct(input: JSON) throws -> SuiMoveNormalizedStruct {
        let abilities = input["abilities"]["abilities"].arrayValue
        let typeParameters = input["typeParameters"].arrayValue
        let fields = input["fields"].arrayValue
        return SuiMoveNormalizedStruct(
            abilities: SuiMoveAbilitySet(abilities: abilities.map { $0.stringValue }),
            typeParameters: typeParameters.map {
                SuiMoveStructTypeParameter(
                    constraints: SuiMoveAbilitySet(
                        abilities: $0["isPhantom"]["abilities"].arrayValue.map { $0.stringValue }
                    ),
                    isPhantom: $0["isPhantom"].boolValue
                )
            },
            fields: try fields.map {
                SuiMoveNormalizedField(
                    name: $0["name"].stringValue,
                    type: try SuiMoveNormalizedType.decodeNormalizedType($0["type"])
                )
            }
        )
    }

    private func parseNormalizedFunction(input: JSON) throws -> SuiMoveNormalizedFunction {
        let typeParameters = input["typeParameters"].arrayValue
        let parameters = input["parameters"].arrayValue
        let returnValues = input["return"].arrayValue
        return SuiMoveNormalizedFunction(
            visibility: SuiMoveVisibility(rawValue: input["visibility"].stringValue)!,
            isEntry: input["isEntry"].boolValue,
            typeParameters: typeParameters.map { param in
                let abilities = param["abilities"].arrayValue
                return SuiMoveAbilitySet(abilities: abilities.map { $0.stringValue })
            },
            parameters: try parameters.map { try SuiMoveNormalizedType.decodeNormalizedType($0) },
            returnValues: try returnValues.map { try SuiMoveNormalizedType.decodeNormalizedType($0) }
        )
    }

    private func parseNormalizedModule(input: JSON) throws -> SuiMoveNormalizedModule {
        var structs: [String: SuiMoveNormalizedStruct] = [:]
        var exposedFunctions: [String: SuiMoveNormalizedFunction] = [:]
        for (structKey, structValue) in input["structs"].dictionaryValue {
            structs[structKey] = try self.parseNormalizedStruct(input: structValue)
        }
        for (exposedKey, exposedValue) in input["exposedFunctions"].dictionaryValue {
            exposedFunctions[exposedKey] = try self.parseNormalizedFunction(input: exposedValue)
        }
        return SuiMoveNormalizedModule(
            fileFormatVersion: input["fileFormatVersion"].intValue,
            address: input["address"].stringValue,
            name: input["name"].stringValue,
            friends: input["friends"].arrayValue.map {
                SuiMoveModuleId(
                    address: $0["address"].stringValue,
                    name: $0["name"].stringValue
                )
            },
            structs: structs,
            exposedFunctions: exposedFunctions
        )
    }

    private func parseObject(input: JSON) throws -> SuiObjectResponse {
        var error: ObjectResponseError? = nil
        if input["error"].exists() {
            error = ObjectResponseError.parseJSON(input["error"])
        }
        let data = input["data"]
        return SuiObjectResponse(
            error: error,
            data: self.parseObjectData(data: data)
        )
    }

    private func parseObjectData(data: JSON) -> SuiObjectData {
        return SuiObjectData(
            bcs: RawData.parseJSON(data["bcs"]),
            content: SuiParsedData.parseJSON(data["content"]),
            digest: data["digest"].stringValue,
            display: DisplayFieldsResponse.parseJSON(data["display"]),
            objectId: data["objectId"].stringValue,
            owner: ObjectOwner.parseJSON(data["owner"]),
            previousTransaction: data["previousTransaction"].stringValue,
            storageRebate: data["storageRebate"].int,
            type: data["type"].string,
            version: data["version"].uInt64Value
        )
    }

    private func parseObjectRef(data: JSON) -> SuiObjectRef {
        return SuiObjectRef(
            objectId: data["objectId"].stringValue,
            version: data["version"].uInt64Value,
            digest: data["digest"].stringValue
        )
    }

    private func parseObjectRead(_ data: JSON) -> ObjectRead? {
        switch data["status"].stringValue {
        case "VersionFound":
            return .versionFound(self.parseObjectData(data: data["details"]))
        case "ObjectNotExists":
            return .objectNotExists(data["details"].stringValue)
        case "ObjectDeleted":
            return .objectDeleted(self.parseObjectRef(data: data["details"]))
        case "VersionNotFound":
            return .versionNotFound(
                data["details"].arrayValue[0].stringValue,
                data["details"].arrayValue[1].stringValue
            )
        case "VersionTooHigh":
            return .versionTooHigh(
                askedVersion: data["details"]["askedVersion"].stringValue,
                latestVersion: data["details"]["latestVersion"].stringValue,
                objectId: data["details"]["objectId"].stringValue
            )
        default:
            return nil
        }
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

    private func isValidSuiAddress(_ value: String) -> Bool {
        return isHex(value) && self.getHexByteLength(value) == 32
    }

    private func isHex(_ value: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(0x|0X)?[a-fA-F0-9]+$")
        let range = NSRange(location: 0, length: value.utf16.count)
        let match = regex.firstMatch(in: value, options: [], range: range)
        
        return match != nil && value.count % 2 == 0
    }
    
    private func getHexByteLength(_ value: String) -> Int {
        if value.hasPrefix("0x") || value.hasPrefix("0X") {
            return (value.count - 2) / 2
        } else {
            return value.count / 2
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

public enum SuiObjectDataFilter: Codable {
    case MatchAll([SuiObjectDataFilter])
    case MatchAny([SuiObjectDataFilter])
    case MatchNone([SuiObjectDataFilter])
    case Package(String)
    case MoveModule(MoveModuleFilter)
    case StructType(String)
    case AddressOwner(String)
    case ObjectOwner(String)
    case ObjectId(String)
    case ObjectIds([String])
    case Version(String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .MatchAll(let array):
            try container.encode(array, forKey: .MatchAll)
        case .MatchAny(let array):
            try container.encode(array, forKey: .MatchAny)
        case .MatchNone(let array):
            try container.encode(array, forKey: .MatchNone)
        case .Package(let string):
            try container.encode(string, forKey: .Package)
        case .MoveModule(let moveModuleFilter):
            try container.encode(moveModuleFilter, forKey: .MoveModule)
        case .StructType(let string):
            try container.encode(string, forKey: .StructType)
        case .AddressOwner(let string):
            try container.encode(string, forKey: .AddressOwner)
        case .ObjectOwner(let string):
            try container.encode(string, forKey: .ObjectOwner)
        case .ObjectId(let string):
            try container.encode(string, forKey: .ObjectId)
        case .ObjectIds(let array):
            try container.encode(array, forKey: .ObjectId)
        case .Version(let string):
            try container.encode(string, forKey: .Version)
        }
    }
}

public struct MoveModuleFilter: Codable {
    public var module: String
    public var package: String
}

public struct SuiObjectDataOptions: Codable {
    public var showBcs: Bool?
    public var showContent: Bool?
    public var showDisplay: Bool?
    public var showOwner: Bool?
    public var showPreviousTransaction: Bool?
    public var showStorageRebate: Bool?
    public var showType: Bool?
}

public struct DynamicFieldPage {
    public var data: [DynamicFieldInfo]
    public var nextCursor: String?
    public var hasNextPage: Bool
}

public struct DynamicFieldInfo {
    public var bcsName: String
    public var digest: String
    public var name: DynamicFieldName
    public var objectId: String
    public var objectType: String
    public var type: DynamicFieldType
    public var version: String
}

public struct DynamicFieldName: Codable {
    public var type: String
    public var value: String
}

public enum DynamicFieldType: String {
    case dynamicField = "DynamicField"
    case dynamicObject = "DynamicObject"
}

public struct DelegatedStake {
    public var stakes: [StakeStatus]
    public var stakingPool: String
    public var validatorAddress: String
}

public struct StakeObject: Equatable {
    public var principal: String
    public var stakeActiveEpoch: String
    public var stakeRequestEpoch: String
    public var stakeSuiId: String
}

public enum StakeStatus: Equatable {
    case pending(StakeObject)
    case active(StakeObject)
    case unstaked(StakeObject)

    public func getStakeObject() -> StakeObject {
        switch self {
        case .pending(let stakeObject):
            return stakeObject
        case .active(let stakeObject):
            return stakeObject
        case .unstaked(let stakeObject):
            return stakeObject
        }
    }
}

public struct CommitteeInfo {
    public var epoch: String
    public var validators: [[String]]
}

public enum SuiMoveFunctionArgType: Equatable {
    case pure
    case object(ObjectValueKind)
}

public enum ObjectValueKind: String, Equatable {
    case byImmutableReference = "ByImmutableReference"
    case byMutableReference = "ByMutableReference"
    case byValue = "ByValue"
}

public struct SuiObjectResponseQuery: Codable {
    public var filter: SuiObjectDataFilter?
    public var options: SuiObjectDataOptions?
}

public struct PaginatedObjectsResponse {
    public var data: [SuiObjectResponse]
    public var hasNextPage: Bool
    public var nextCursor: String?
}

public struct DisplayFieldsResponse {
    public var data: [String: String]?
    public var error: ObjectResponseError?

    public static func parseJSON(_ input: JSON) -> DisplayFieldsResponse? {
        var error: ObjectResponseError? = nil
        if input["error"].exists() {
            error = ObjectResponseError.parseJSON(input["error"])
        }
        var data: [String: String] = [:]
        for (key, value) in input["data"].dictionaryValue {
            data[key] = value.stringValue
        }
        return DisplayFieldsResponse(data: data, error: error)
    }
}

public enum ObjectResponseError: Error, Equatable {
    case notExist(objectId: String)
    case dynamicFieldNotFound(parentObjectId: String)
    case deleted(digest: String, objectId: String, version: String)
    case unknown
    case displayError(error: String)

    public static func parseJSON(_ input: JSON) -> ObjectResponseError? {
        switch input["code"].stringValue {
        case "notExist":
            return .notExist(objectId: input["objectId"].stringValue)
        case "dynamicFieldNotFound":
            return .dynamicFieldNotFound(parentObjectId: input["parentObjectId"].stringValue)
        case "deleted":
            return .deleted(
                digest: input["digest"].stringValue,
                objectId: input["objectId"].stringValue,
                version: input["version"].stringValue
            )
        case "unknown":
            return .unknown
        case "displayError":
            return .displayError(error: input["error"].stringValue)
        default:
            return nil
        }
    }
}

public enum ObjectRead {
    case versionFound(SuiObjectData)
    case objectNotExists(String)
    case objectDeleted(SuiObjectRef)
    case versionNotFound(String, String)
    case versionTooHigh(askedVersion: String, latestVersion: String, objectId: String)

    public func status() -> String {
        switch self {
        case .versionFound:
            return "VersionFound"
        case .objectNotExists:
            return "ObjectNotExists"
        case .objectDeleted:
            return "ObjectDeleted"
        case .versionNotFound:
            return "VersionNotFound"
        case .versionTooHigh:
            return "VersionTooHigh"
        }
    }
}
