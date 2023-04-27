//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct GetObject: Codable {
    public var showType: Bool
    public var showOwner: Bool
    public var showPreviousTransaction: Bool
    public var showDisplay: Bool
    public var showContent: Bool
    public var showBcs: Bool
    public var showStorageRebate: Bool
    
    public init(
        showType: Bool = true,
        showOwner: Bool = true,
        showPreviousTransaction: Bool = true,
        showDisplay: Bool = true,
        showContent: Bool = true,
        showBcs: Bool = true,
        showStorageRebate: Bool = true
    ) {
        self.showType = showType
        self.showOwner = showOwner
        self.showPreviousTransaction = showPreviousTransaction
        self.showDisplay = showDisplay
        self.showContent = showContent
        self.showBcs = showBcs
        self.showStorageRebate = showStorageRebate
    }
}
