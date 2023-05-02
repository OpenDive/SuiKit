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

public struct SuiClient {
    public var clientConfig: ClientConfig
    
    public init(clientConfig: ClientConfig) {
        self.clientConfig = clientConfig
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
    
    public func totalSupply(_ coinType: String = "0x2::sui::SUI") async throws -> UInt64 {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getTotalSupply", [AnyCodable(coinType)])
        )
        return try JSONDecoder().decode(JSON.self, from: data)["result"]["value"].uInt64Value
    }
    
    public func getAllBalances(_ account: AccountAddress) async throws -> [Balance] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllBalances", [
                AnyCodable(account.description)
            ])
        )
        var balances: [Balance] = []
        for (_, value):(String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"] {
            balances.append(
                Balance(
                    coinType: value["coinType"].stringValue,
                    coinObjectCount: value["coinObjectCount"].intValue,
                    totalBalance: value["totalBalance"].uInt64Value
                )
            )
        }
        return balances
    }
    
    public func getBalance(_ account: AccountAddress, _ coinType: String = "0x2::sui::SUI") async throws -> Balance {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getBalance", [
                AnyCodable(account.description),
                AnyCodable(coinType)
            ])
        )
        let value = try JSONDecoder().decode(JSON.self, from: data)["result"]
        return Balance(
            coinType: value["coinType"].stringValue,
            coinObjectCount: value["coinObjectCount"].intValue,
            totalBalance: value["totalBalance"].uInt64Value
        )
    }
    
    public func getAllCoins(_ account: AccountAddress, _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> [CoinPage] {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest("suix_getAllCoins", [
                AnyCodable(account.description),
                AnyCodable(cursor),
                AnyCodable(limit)
            ])
        )
        var coinPages: [CoinPage] = []
        for (_, value):(String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"]["data"] {
            coinPages.append(
                CoinPage(
                    coinType: value["coinType"].stringValue,
                    coinObjectId: value["coinObjectId"].stringValue,
                    version: value["version"].stringValue,
                    digest: value["digest"].stringValue,
                    balance: value["balance"].uInt64Value,
                    previousTransaction: value["previousTransaction"].stringValue
                )
            )
        }
        return coinPages
    }
    
    public func getCoins(_ account: AccountAddress, _ coinType: String = "0x2::sui::SUI", _ cursor: String? = nil, _ limit: UInt? = nil) async throws -> [CoinPage] {
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
        var coinPages: [CoinPage] = []
        for (_, value):(String, JSON) in try JSONDecoder().decode(JSON.self, from: data)["result"]["data"] {
            coinPages.append(
                CoinPage(
                    coinType: value["coinType"].stringValue,
                    coinObjectId: value["coinObjectId"].stringValue,
                    version: value["version"].stringValue,
                    digest: value["digest"].stringValue,
                    balance: value["balance"].uInt64Value,
                    previousTransaction: value["previousTransaction"].stringValue
                )
            )
        }
        return coinPages
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
        return SuiObjectResponse(
            objectId: value["objectId"].stringValue,
            version: value["version"].intValue,
            digest: value["digest"].stringValue,
            type: value["type"].stringValue,
            owner: SuiObjectOwner(addressOwner: value["owner"]["AddressOwner"].stringValue),
            previousTransaction: value["previousTransaction"].stringValue,
            storageRebate: value["storageRebate"].intValue,
            content: SuiMoveObject(
                dataType: value["content"]["dataType"].stringValue,
                type: value["content"]["type"].stringValue,
                hasPublicTransfer: value["content"]["hasPublicTransfer"].boolValue,
                fields: value["content"]["fields"]
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
                        dataType: value["content"]["dataType"].stringValue,
                        type: value["content"]["type"].stringValue,
                        hasPublicTransfer: value["content"]["hasPublicTransfer"].boolValue,
                        fields: value["content"]["fields"]
                    )
                )
            )
        }
        return result
    }
    
    public func pay(_ sender: Account, _ coin: String, _ gasCoin: String, _ receiver: AccountAddress, _ amount: Int,  _ gasBudget: Int) async throws -> TransactionResponse {
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
    
    public func paySui(_ sender: Account, _ receiver: AccountAddress, _ amount: Int, _ gasBudget: Int, _ coin: String) async throws -> TransactionResponse {
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
    
    public func transferSui(_ sender: Account, _ receiver: AccountAddress, _ gasBudget: Int, _ amount: UInt64, _ suiObjectId: String) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_transferSui",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable(suiObjectId),
                    AnyCodable("\(gasBudget)"),
                    AnyCodable(receiver.description),
                    AnyCodable("\(amount)")
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func splitCoin(_ signer: Account, _ coinObjectId: String, _ splitAmount: Int, _ gas: String, _ gasBudget: Int) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_splitCoin",
                [
                    AnyCodable(signer.accountAddress.description),
                    AnyCodable(coinObjectId),
                    AnyCodable("\(splitAmount)"),
                    AnyCodable(gas),
                    AnyCodable("\(gasBudget)")
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func publish(_ sender: Account, _ compiledModules: [String], _ dependencies: [String], _ gas: String, _ gasBudget: Int) async throws -> TransactionResponse {
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
        _ typeArguments: [String],
        _ arguments: [String],
        _ gas: String,
        _ gasBudget: Int,
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
                    AnyCodable("\(gasBudget)"),
                    AnyCodable(executionMode.asString())
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func transferObject(_ sender: Account, _ receiver: AccountAddress, _ objectId: String, _ gas: String, _ gasBudget: Int) async throws -> TransactionResponse {
        let data = try await self.sendSuiJsonRpc(
            try self.getServerUrl(),
            SuiRequest(
                "unsafe_transferObject",
                [
                    AnyCodable(sender.accountAddress.description),
                    AnyCodable(objectId),
                    AnyCodable(gas),
                    AnyCodable("\(gasBudget)"),
                    AnyCodable(receiver.description)
                ]
            )
        )
        return try await self.getTransactionResponse(data)
    }
    
    public func executeTransactionBlocks(_ txBlock: TransactionResponse, _ signer: Account) async throws -> TransactionResponse {
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
        
        return try await self.getTransactionResponse(data)
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
        guard let url = URL(string: self.clientConfig.baseUrl) else {
            throw SuiError.invalidUrl(url: self.clientConfig.baseUrl)
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
            print(JSON(requestData))
        } catch {
            throw SuiError.encodingError
        }
        
        return try await withCheckedThrowingContinuation { (con: CheckedContinuation<Data, Error>) in
            let task = URLSession.shared.dataTask(with: requestUrl) { data, _, error in
                print(JSON(data ?? "NONE"))
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
