//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct EndOfEpochData {
    let nextEpochComittee: [(String, String)]
    let nextEpochProtocolVersion: String
    let epochCommitments: [CheckpointComitment]
}

public typealias CheckpointComitment = Any
