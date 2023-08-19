//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import AnyCodable
import SwiftyJSON

public struct EventId: Codable {
    public let txDigest: TransactionDigest
    public let eventSeq: SequenceNumber

    public static func parseJSON(_ input: JSON) -> EventId {
        return EventId(
            txDigest: input["txDigest"].stringValue,
            eventSeq: input["eventSeq"].stringValue
        )
    }
}

public struct SuiEvent {
    public let id: EventId
    public let packageId: objectId
    public let transactionModule: String
    public let sender: AccountAddress
    public let type: String
    public let parsedJson: JSON
    public let bcs: String?
    public let timestampMs: String?

    public init?(input: JSON) {
        guard let sender = try? AccountAddress.fromHex(input["sender"].stringValue) else { return nil }
        self.id = EventId.parseJSON(input["id"])
        self.packageId = input["packageId"].stringValue
        self.transactionModule = input["transactionModule"].stringValue
        self.sender = sender
        self.type = input["type"].stringValue
        self.parsedJson = input["parsedJson"]
        self.bcs = input["bcs"].string
        self.timestampMs = input["timestampMs"].string
    }
}
