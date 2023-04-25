//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation

public struct SuiClientError: Codable, Error {
    let jsonrpc: String
    let error: SuiClientMessage
    let id: Int
}

public struct SuiClientMessage: Codable, Error {
    let code: Int
    let message: String
}
