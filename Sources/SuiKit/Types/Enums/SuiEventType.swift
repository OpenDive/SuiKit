//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public enum SuiEventType: String {
    case none = "None"
    case moveEvent = "MoveEvent"
    case publish = "Publish"
    case transferObject = "TransferObject"
    case deleteObject = "DeleteObject"
    case newObject = "NewObject"
    case epochChange = "EpochChange"
    case checkpoint = "Checkpoint"
    case mutateObject = "MutateObject"
    case coinBalanceChange = "CoinBalanceChange"
}
