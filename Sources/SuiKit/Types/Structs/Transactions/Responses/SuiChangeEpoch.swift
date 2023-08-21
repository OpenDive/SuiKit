//
//  SuiChangeEpoch.swift
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

public struct SuiChangeEpoch: Codable, KeyProtocol {
    public let epoch: EpochId
    public let storageCharge: String
    public let computationCharge: String
    public let storageRebate: String
    public let epochStartTimestampMs: String?

    public init(
        epoch: EpochId,
        storageCharge: String,
        computationCharge: String,
        storageRebate: String,
        epochStartTimestampMs: String?
    ) {
        self.epoch = epoch
        self.storageCharge = storageCharge
        self.computationCharge = computationCharge
        self.storageRebate = storageRebate
        self.epochStartTimestampMs = epochStartTimestampMs
    }

    public init(input: JSON) {
        self.epoch = input["epoch"].stringValue
        self.storageCharge = input["storageCharge"].stringValue
        self.computationCharge = input["computationCharge"].stringValue
        self.storageRebate = input["storageRebate"].stringValue
        self.epochStartTimestampMs = input["epochStartTimestampMs"].string
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, epoch)
        try Serializer.str(serializer, storageCharge)
        try Serializer.str(serializer, computationCharge)
        try Serializer.str(serializer, storageRebate)
        
        if let epochStartTimestampMs {
            try Serializer.str(serializer, epochStartTimestampMs)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiChangeEpoch {
        return SuiChangeEpoch(
            epoch: try Deserializer.string(deserializer),
            storageCharge: try Deserializer.string(deserializer),
            computationCharge: try Deserializer.string(deserializer),
            storageRebate: try Deserializer.string(deserializer),
            epochStartTimestampMs: try Deserializer.string(deserializer)
        )
    }
}
