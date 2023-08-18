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
    public let sender: SuiAddress
    public let type: String
    public let parsedJson: JSON
    public let bcs: String?
    public let timestampMs: String?
}
