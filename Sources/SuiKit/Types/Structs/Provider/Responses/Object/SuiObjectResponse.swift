//
//  File.swift
//
//
//  Created by Marcus Arnett on 4/25/23.
//

import Foundation
import SwiftyJSON

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

    public init(error: ObjectResponseError? = nil, data: SuiObjectData? = nil) {
        self.error = error
        self.data = data
    }

    public init?(input: JSON) {
        var error: ObjectResponseError? = nil
        if input["error"].exists() {
            error = ObjectResponseError.parseJSON(input["error"])
        }
        let data = input["data"]
        self.error = error
        self.data = SuiObjectData(data: data)
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
    public let version: String

    public init(
        bcs: RawData?,
        content: SuiParsedData?,
        digest: String,
        display: DisplayFieldsResponse?,
        objectId: String,
        owner: ObjectOwner?,
        previousTransaction: String?,
        storageRebate: Int?,
        type: String?,
        version: String
    ) {
        self.bcs = bcs
        self.content = content
        self.digest = digest
        self.display = display
        self.objectId = objectId
        self.owner = owner
        self.previousTransaction = previousTransaction
        self.storageRebate = storageRebate
        self.type = type
        self.version = version
    }

    public init?(data: JSON) {
        self.bcs = RawData.parseJSON(data["bcs"])
        self.content = SuiParsedData.parseJSON(data["content"])
        self.digest = data["digest"].stringValue
        self.display = DisplayFieldsResponse.parseJSON(data["display"])
        self.objectId = data["objectId"].stringValue
        self.owner = ObjectOwner.parseJSON(data["owner"])
        self.previousTransaction = data["previousTransaction"].stringValue
        self.storageRebate = data["storageRebate"].int
        self.type = data["type"].string
        self.version = data["version"].stringValue
    }
}
