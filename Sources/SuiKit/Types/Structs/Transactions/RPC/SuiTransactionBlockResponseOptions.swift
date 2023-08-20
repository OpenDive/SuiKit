//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public struct SuiTransactionBlockResponseOptions: Codable {
    public let showInput: Bool?
    public let showEffects: Bool?
    public let showEvents: Bool?
    public let showObjectChanges: Bool?
    public let showBalanceChanges: Bool?

    public init(
        showInput: Bool? = nil,
        showEffects: Bool? = nil,
        showEvents: Bool? = nil,
        showObjectChanges: Bool? = nil,
        showBalanceChanges: Bool? = nil
    ) {
        self.showInput = showInput
        self.showEffects = showEffects
        self.showEvents = showEvents
        self.showObjectChanges = showObjectChanges
        self.showBalanceChanges = showBalanceChanges
    }
}
