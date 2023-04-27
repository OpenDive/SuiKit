//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation
import SwiftyJSON
import AnyCodable

public struct SuiClient {
    public var clientConfig: ClientConfig
    
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
