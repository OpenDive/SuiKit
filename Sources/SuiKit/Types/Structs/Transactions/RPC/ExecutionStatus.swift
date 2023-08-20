//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct ExecutionStatus {
    public let status: ExecutionStatusType
    public let error: String?

    public init?(input: JSON) {
        guard let status = ExecutionStatusType.fromJSON(input["status"]) else { return nil }
        self.status = status
        self.error = input["error"].string
    }
}
