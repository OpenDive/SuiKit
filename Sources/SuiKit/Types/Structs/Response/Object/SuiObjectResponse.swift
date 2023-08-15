//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation

public struct SuiObjectResponse {
    public let objectId: String
    public let version: UInt64
    public let digest: String
    public let type: String?
    public let owner: ObjectOwner?
    public let previousTransaction: String?
    public let storageRebate: Int?
    public let content: SuiMoveObject
    public let error: String?

    public func getSharedObjectInitialVersion() -> Int? {
        if let owner = self.owner, let initialSharedVersion = owner.shared?.shared.initialSharedVersion, initialSharedVersion != 0 {
            return initialSharedVersion
        }
        return nil
    }

    public func getObjectReference() -> SuiObjectRef {
        return SuiObjectRef(
            objectId: self.objectId,
            version: self.version,
            digest: self.digest
        )
    }
}
