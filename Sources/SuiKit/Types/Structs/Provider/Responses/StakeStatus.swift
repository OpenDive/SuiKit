//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation

public enum StakeStatus: Equatable {
    case pending(StakeObject)
    case active(StakeObject)
    case unstaked(StakeObject)

    public func getStakeObject() -> StakeObject {
        switch self {
        case .pending(let stakeObject):
            return stakeObject
        case .active(let stakeObject):
            return stakeObject
        case .unstaked(let stakeObject):
            return stakeObject
        }
    }
}
