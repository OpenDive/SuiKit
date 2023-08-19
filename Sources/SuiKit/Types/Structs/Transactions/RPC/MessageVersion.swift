//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum MessageVersion: String {
    case v1

    public static func fromJSON(_ input: JSON) -> MessageVersion? {
        switch input.stringValue {
        case "v1":
            return .v1
        default:
            return nil
        }
    }
}
