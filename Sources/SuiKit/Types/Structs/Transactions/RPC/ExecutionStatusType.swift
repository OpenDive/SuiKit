//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum ExecutionStatusType: String, Equatable {
    case success
    case failure

    public static func fromJSON(_ input: JSON) -> ExecutionStatusType? {
        switch input.stringValue {
        case "success":
            return .success
        case "failure":
            return .failure
        default:
            return nil
        }
    }
}
