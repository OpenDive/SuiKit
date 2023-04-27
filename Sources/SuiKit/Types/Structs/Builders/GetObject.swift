//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct GetObject: Codable {
    let showType: Bool
    let showOwner: Bool
    let showPreviousTransaction: Bool
    let showDisplay: Bool
    let showContent: Bool
    let showBcs: Bool
    let showStorageRebate: Bool
}
