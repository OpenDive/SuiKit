//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation

public struct localnetConnection: ConnectionProtcol {
    public var fullNode: String = "http://127.0.0.1:9000"
    public var faucet: String? = "http://127.0.0.1:9123/gas"

    public init() { }
}

public struct devnetConnection: ConnectionProtcol {
    public var fullNode: String = "https://fullnode.devnet.sui.io:443/"
    public var faucet: String? = "https://faucet.devnet.sui.io/gas"

    public init() { }
}

public struct testnetConnection: ConnectionProtcol {
    public var fullNode: String = "https://fullnode.testnet.sui.io:443/"
    public var faucet: String? = "https://faucet.testnet.sui.io/gas"

    public init() { }
}

public struct mainnetConnection: ConnectionProtcol {
    public var fullNode: String = "https://fullnode.mainnet.sui.io:443/"

    public init() { }
}
