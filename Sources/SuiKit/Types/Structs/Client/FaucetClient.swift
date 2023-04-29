//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation

public struct FaucetClient {
    public let baseUrl: String
    
    public func funcAccount(_ address: String) async throws {
        guard let url = URL(string: baseUrl) else {
            throw SuiError.invalidUrl(url: baseUrl)
        }
        let data: [String: Any] = [
            "FixedAmountRequest": [
                "recipient": address
            ]
        ]
        try await URLSession.shared.decodeUrl(with: url, data)
    }
}
