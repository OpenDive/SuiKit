//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct RPCErrorValue: Equatable {
    public let id: Int?
    public let error: ErrorMessage?
    public let jsonrpc: String?
    public let hasError: Bool
}
