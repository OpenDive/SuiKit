//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct DevInspectResults {
    public var effects: TransactionEffects
    public var error: String?
    public var events: [SuiEvent]

    public init?(input: JSON) {
        guard let effects = TransactionEffects(input: input["effects"]) else { return nil }
        self.effects = effects
        self.error = input["error"].string
        self.events = input["events"].arrayValue.compactMap { SuiEvent(input: $0) }
    }
}
