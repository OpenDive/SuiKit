//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
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
