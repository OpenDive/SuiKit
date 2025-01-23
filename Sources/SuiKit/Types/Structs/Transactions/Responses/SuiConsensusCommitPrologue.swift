//
//  SuiConsensusCommitPrologue.swift
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

public struct SuiConsensusCommitPrologue: Codable, KeyProtocol {
    /// An `EpochId` representing the identifier of the epoch.
    public let epoch: EpochId

    /// A `String` representing the round within the consensus process.
    public let round: String

    /// A `String` representing the timestamp at which the consensus commit occurred, in milliseconds.
    public let commitTimestampMs: String

    public init(epoch: EpochId, round: String, commitTimestampMs: String) {
        self.epoch = epoch
        self.round = round
        self.commitTimestampMs = commitTimestampMs
    }

    public init(input: JSON) {
        self.epoch = input["epoch"].stringValue
        self.round = input["round"].stringValue
        self.commitTimestampMs = input["commitTimestampMs"].stringValue
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, epoch)
        try Serializer.str(serializer, round)
        try Serializer.str(serializer, commitTimestampMs)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SuiConsensusCommitPrologue {
        return SuiConsensusCommitPrologue(
            epoch: try Deserializer.string(deserializer),
            round: try Deserializer.string(deserializer),
            commitTimestampMs: try Deserializer.string(deserializer)
        )
    }
}
