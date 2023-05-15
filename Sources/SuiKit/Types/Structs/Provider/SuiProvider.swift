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
    
    public func getAllBalances(_ account: AccountAddress) async throws -> [CoinBalance] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllBalances", [
                AnyCodable(account.description)
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
    
    public func getBalance(_ account: AccountAddress, _ coinType: String) async throws -> CoinBalance {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getBalance", [
                AnyCodable(account.description),
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
    
    public func getAllCoins(_ account: AccountAddress, _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> PaginatedCoins {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllCoins", [
                AnyCodable(account.description),
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
    
    public func getCoins(_ account: AccountAddress, _ coinType: String, _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> PaginatedCoins {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getCoins",
                [
                    AnyCodable(account.description),
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
            version: value["version"].intValue,
            digest: value["digest"].stringValue,
            type: value["type"].stringValue,
            owner: SuiObjectOwner(addressOwner: value["owner"]["AddressOwner"].stringValue),
            previousTransaction: value["previousTransaction"].stringValue,
            storageRebate: value["storageRebate"].intValue,
            content: SuiMoveObject(
                type: value["content"]["type"].stringValue,
                fields: fields,
                hasPublicTransfer: value["content"]["hasPublicTransfer"].boolValue
            )
        )
    }
    
    public func getOwnedObjects(_ account: AccountAddress, _ query: GetOwnedObjects = GetOwnedObjects(), _ cursor: String? = nil, _ limit: Int? = nil) async throws -> [SuiObjectResponse] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "suix_getOwnedObjects",
                [
                    AnyCodable(account.description),
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
                    version: value["version"].intValue,
                    digest: value["digest"].stringValue,
                    type: value["type"].stringValue,
                    owner: SuiObjectOwner(addressOwner: value["owner"]["AddressOwner"].stringValue),
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
    
    public func pay(_ sender: Account, _ coin: String, _ gasCoin: String, _ receiver: AccountAddress, _ amount: String,  _ gasBudget: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_pay",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable([coin]),
                    AnyCodable([receiver.description]),
                    AnyCodable([amount]),
                    AnyCodable(gasCoin),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func paySui(_ sender: Account, _ receiver: AccountAddress, _ amount: String, _ gasBudget: String, _ coin: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_paySui",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable([coin]),
                    AnyCodable([receiver.description]),
                    AnyCodable([amount]),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func payAllSui(_ sender: Account, _ receiver: AccountAddress, _ inputCoin: String, _ gasBudget: Int) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_payAllSui",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable([inputCoin]),
                    AnyCodable(receiver.description),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func transferSui(_ sender: Account, _ receiver: AccountAddress, _ gasBudget: String, _ amount: String, _ suiObjectId: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_transferSui",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable(suiObjectId),
                    AnyCodable(gasBudget),
                    AnyCodable(receiver.description),
                    AnyCodable(amount)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func transferObject(_ sender: Account, _ objectId: objectId, _ gas: objectId, _ gasBudget: String, _ recipient: AccountAddress) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_transferObject",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable(objectId),
                    AnyCodable(gas),
                    AnyCodable(gasBudget),
                    AnyCodable(recipient.description)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func splitCoin(_ signer: Account, _ coinObjectId: String, _ splitAmount: String, _ gas: String, _ gasBudget: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_splitCoin",
                [
                    AnyCodable(signer.accountAddress.description),
                    AnyCodable(coinObjectId),
                    AnyCodable(splitAmount),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func mergeCoin(_ signer: Account, _ primaryCoin: objectId, _ coinToMerge: objectId, _ gas: objectId, _ gasBudget: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_mergeCoins",
                [
                    AnyCodable(signer.accountAddress.description),
                    AnyCodable(primaryCoin),
                    AnyCodable(coinToMerge),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func publish(_ sender: Account, _ compiledModules: [String], _ dependencies: [String], _ gas: String, _ gasBudget: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_publish",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable(compiledModules),
                    AnyCodable(dependencies),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func moveCall(
        _ sender: Account,
        _ packageObjectId: String,
        _ module: String,
        _ function: String,
        _ typeArguments: [TypeTag],
        _ arguments: [String],
        _ gas: String,
        _ gasBudget: String,
        _ executionMode: SuiTransactionBuilderMode
    ) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_moveCall",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable(packageObjectId),
                    AnyCodable(module),
                    AnyCodable(function),
                    AnyCodable(typeArguments),
                    AnyCodable(arguments),
                    AnyCodable(gas),
                    AnyCodable(gasBudget),
                    AnyCodable(executionMode.asString())
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func requestAddStake(_ signer: Account, _ coins: [String], _ amount: String, _ validators: SuiAddress, _ gas: objectId, _ gasBudget: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_requestAddStake",
                [
                    AnyCodable(signer.accountAddress.description),
                    AnyCodable(coins),
                    AnyCodable(amount),
                    AnyCodable(validators),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func requestWithdrawStake(_ signer: Account, _ stakedSui: objectId, _ gas: objectId, _ gasBudget: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_requestWithdrawStake",
                [
                    AnyCodable(signer.accountAddress.description),
                    AnyCodable(stakedSui),
                    AnyCodable(gas),
                    AnyCodable(gasBudget)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func executeTransactionBlocks(_ txBlock: TransactionResponse, _ signer: Account) async throws -> JSON {
        // 1. Create byte array of 3 '0' elements (this is called the intent)
        let flag: [UInt8] = [0, 0, 0]
        
        // 2. Append the base64 tx_bytes decoded to bytes
        guard let txDecoded = Data.fromBase64(txBlock.txBytes) else {
            throw SuiError.stringToDataFailure(value: txBlock.txBytes)
        }
        let signatureData = Data(flag) + txDecoded
        
        // 3. Sign the new extended bytes (this is the 'signature') as a Blake2B hash
        let hash = try Blake2.hash(.b2b, size: 32, data: signatureData)
        let signature: Signature = try signer.privateKey.sign(data: hash)
        
        // 4. join the key_flag byte (in your case this will be 0 for ed25519) with the signature and then the public key bytes
        let pubKey = try signer.publicKey().key
        let finalData = Data([0x00]) + signature.signature + pubKey
        
        // 5. Encode using base64
        let finalB64 = finalData.base64EncodedString()
        
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "sui_executeTransactionBlock",
                [
                    AnyCodable(txBlock.txBytes),
                    AnyCodable([finalB64]),
                    AnyCodable(TransactionBlockResponseOptions()),
                    AnyCodable(SuiRequestType.waitForLocalExecution.asString())
                ]
            )
        )
        
        return JSON(data)["result"]
    }
    
    private func getTransactionResponse(_ data: Data) async throws -> TransactionResponse {
        let json = JSON(data)["result"]
        var responseObjects: [String: SuiObjectRef] = [:]
        for objects in JSON(data)["result"]["inputObjects"] {
            let objDict = objects.1.dictionaryValue
            let objValue = objDict.values.first!
            responseObjects["\(objDict.keys.first!)"] = SuiObjectRef(
                version: objValue["version"].uInt8Value,
                objectId: objValue["objectId"].stringValue,
                digest: objValue["digest"].stringValue
            )
        }
        return TransactionResponse(
            txBytes: json["txBytes"].stringValue,
            gas: SuiObjectRef(
                version: json["gas"][0]["version"].uInt8Value,
                objectId: json["gas"][0]["objectId"].stringValue,
                digest: json["gas"][0]["digest"].stringValue
            ),
            inputObjects: responseObjects
        )
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
