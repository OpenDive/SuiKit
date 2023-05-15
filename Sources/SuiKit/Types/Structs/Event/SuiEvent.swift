//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import AnyCodable

public struct EventId {
    public let txDigest: TransactionDigest
    public let eventSeq: SequenceNumber
}

public struct SuiEvent {
    public let id: EventId
    public let packageId: objectId
    public let transactionModule: String
    public let sender: SuiAddress
    public let type: String
    public let parsedJson: [String: AnyCodable]?
    public let bcs: String?
    public let timestampMs: String?
}
