//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation
import SwiftyJSON

public struct FaucetClient {
    public let connection: any ConnectionProtcol
    
    public init(connection: any ConnectionProtcol) {
        self.connection = connection
    }
    
    public func funcAccount(_ address: String) async throws -> FaucetCoinInfo {
        guard let baseUrl = connection.faucet else {
            throw SuiError.faucetUrlRequired
        }
        guard let url = URL(string: baseUrl) else {
            throw SuiError.invalidUrl(url: baseUrl)
        }
        let data: [String: Any] = [
            "FixedAmountRequest": [
                "recipient": address
            ]
        ]
        
        do {
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json"
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
            request.httpMethod = "POST"
            let result = try await URLSession.shared.asyncData(with: request)
                
            let json = try JSONDecoder().decode(JSON.self, from: result)["transferredGasObjects"][0]
            return FaucetCoinInfo(amount: json["amount"].intValue, id: json["id"].stringValue, transferTxDigest: json["transferTxDigest"].stringValue)
        } catch {
            throw SuiError.invalidJsonData
        }
    }
}
