//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/27/23.
//

import Foundation

public struct TransactionBlockResponseOptions: Codable {
    public var showInput: Bool
    public var showRawInput: Bool
    public var showEffects: Bool
    public var showEvents: Bool
    public var showObjectChanges: Bool
    public var showBalanceChanges: Bool
    
    public init(
        showInput: Bool = true,
        showRawInput: Bool = true,
        showEffects: Bool = true,
        showEvents: Bool = true,
        showObjectChanges: Bool = true,
        showBalanceChanges: Bool = true
    ) {
        self.showInput = showInput
        self.showRawInput = showRawInput
        self.showEffects = showEffects
        self.showEvents = showEvents
        self.showObjectChanges = showObjectChanges
        self.showBalanceChanges = showBalanceChanges
    }
}
