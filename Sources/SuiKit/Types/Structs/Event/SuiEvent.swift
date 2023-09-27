//
//  SuiEvent.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

public struct SuiEvent {
    /// The unique identifier of the event.
    public let id: EventId

    /// The identifier of the package associated with the event.
    public let packageId: objectId

    /// A string representing the module associated with the transaction.
    public let transactionModule: String

    /// An `AccountAddress` representing the sender of the event.
    public let sender: AccountAddress

    /// A string representing the type of the event.
    public let type: String

    /// A JSON object representing the parsed JSON associated with the event.
    public let parsedJson: JSON

    /// An optional string representing the BCS (Binary Canonical Serialization) of the event.
    public let bcs: String?

    /// An optional string representing the timestamp of the event in milliseconds.
    public let timestampMs: String?

    /// Initializes a new `SuiEvent` with the provided JSON input.
    /// - Parameter input: A JSON object containing the event data.
    /// - Returns: An initialized `SuiEvent` object if the input is valid, otherwise returns nil.
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
