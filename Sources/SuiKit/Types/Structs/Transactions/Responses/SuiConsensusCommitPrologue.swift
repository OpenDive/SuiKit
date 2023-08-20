//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct SuiConsensusCommitPrologue: Codable, KeyProtocol {
    public let epoch: EpochId
    public let round: String
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
