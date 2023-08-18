//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation
import SwiftyJSON

public struct SuiObjectInfo {
    public let suiObjectRef: SuiObjectRef
    public let type: String
    public let owner: ObjectOwner
    public let previousTransaction: TransactionDigest
}

public enum ObjectOwner {
    case addressOwner(String)
    case objectOwner(String)
    case shared(Int)
    case immutable

    public static func parseJSON(_ input: JSON) -> ObjectOwner? {
        if let addressOwner = input["AddressOwner"].string {
            return .addressOwner(addressOwner)
        }

        if let objectOwner = input["ObjectOwner"].string {
            return .objectOwner(objectOwner)
        }

        if let initialSharedVersion = input["Shared"]["initial_shared_version"].int {
            return .shared(initialSharedVersion)
        }

        return nil
    }
}
