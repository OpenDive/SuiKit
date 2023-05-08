//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct CoinBalance {
    public let coinType: String
    public let coinObjectCount: Int
    public let totalBalance: String
    public let lockedBalance: LockedBalance?
}

public struct LockedBalance {
    public let epochId: Int
    public let number: Int
}
