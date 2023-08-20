//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum SuiObjectChange {
    case published(SuiObjectChangePublished)
    case transferred(SuiObjectChangeTransferred)
    case mutated(SuiObjectChangeMutated)
    case deleted(SuiObjectChangeDeleted)
    case wrapped(SuiObjectChangeWrapped)
    case created(SuiObjectChangeCreated)

    public static func fromJSON(_ input: JSON) -> SuiObjectChange? {
        switch input["type"].stringValue {
        case "published":
            return .published(SuiObjectChangePublished(input: input))
        case "transferred":
            guard let transferred = SuiObjectChangeTransferred(input: input) else { return nil }
            return .transferred(transferred)
        case "mutated":
            guard let mutated = SuiObjectChangeMutated(input: input) else { return nil }
            return .mutated(mutated)
        case "deleted":
            guard let deleted = SuiObjectChangeDeleted(input: input) else { return nil }
            return .deleted(deleted)
        case "wrapped":
            guard let wrapped = SuiObjectChangeWrapped(input: input) else { return nil }
            return .wrapped(wrapped)
        case "created":
            guard let created = SuiObjectChangeCreated(input: input) else { return nil }
            return .created(created)
        default:
            return nil
        }
    }

    var kind: String {
        switch self {
        case .published:
            return "published"
        case .transferred:
            return "transferred"
        case .mutated:
            return "mutated"
        case .deleted:
            return "deleted"
        case .wrapped:
            return "wrapped"
        case .created:
            return "created"
        }
    }
}
