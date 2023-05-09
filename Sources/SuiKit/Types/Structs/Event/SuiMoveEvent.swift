//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation
import SwiftyJSON

public struct SuiMoveEvent {
    public let bcs: String
    public let parsedJson: [String: JSON]
    public let packageId: String
    public let sender: String
    public let transactionModule: String
    public let type: String
    public let id: Cursor
}
