//
//  EventId.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftyJSON

/// Represents a unique identifier for an event, typically associated with a transaction.
public struct EventId: Codable {
    /// The digest of the transaction, typically represented by a `TransactionDigest` object.
    public let txDigest: TransactionDigest

    /// The sequence number of the event, typically represented by a `SequenceNumber` object.
    public let eventSeq: SequenceNumber

    /// Parses a JSON object to construct and return an `EventId` instance.
    /// - Parameter input: The JSON object containing the event ID data.
    /// - Returns: An initialized `EventId` object.
    public static func parseJSON(_ input: JSON) -> EventId {
        return EventId(
            txDigest: input["txDigest"].stringValue,
            eventSeq: input["eventSeq"].stringValue
        )
    }
}
