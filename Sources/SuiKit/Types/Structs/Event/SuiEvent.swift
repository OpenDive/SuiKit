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
import AnyCodable
import SwiftyJSON

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
