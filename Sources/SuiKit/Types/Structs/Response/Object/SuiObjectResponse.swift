//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct SuiObjectResponse {
    public var error: ObjectResponseError?
    public var data: SuiObjectData?
    public func getSharedObjectInitialVersion() -> Int? {
        guard let owner = self.data?.owner else { return nil }
        switch owner {
        case .shared(let shared):
            return shared
        default:
            return nil
        }
    }

    public func getObjectReference() -> SuiObjectRef? {
        guard let data = self.data else { return nil }
        return SuiObjectRef(
            objectId: data.objectId,
            version: data.version,
            digest: data.digest
        )
    }
}

public struct SuiObjectData {
    public let bcs: RawData?
    public let content: SuiParsedData?
    public let digest: String
    public let display: DisplayFieldsResponse?
    public let objectId: String
    public let owner: ObjectOwner?
    public let previousTransaction: String?
    public let storageRebate: Int?
    public let type: String?
    public let version: UInt64
}
