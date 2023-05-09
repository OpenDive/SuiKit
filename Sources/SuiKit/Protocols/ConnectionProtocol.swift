//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation

public protocol ConnectionProtcol {
    var fullNode: String { get }
    var faucet: String? { get }
    var websocket: String? { get }
}

public extension ConnectionProtcol {
    var faucet: String? {
        get { return nil }
    }
    
    var websocket: String? {
        get { return nil }
    }
}
