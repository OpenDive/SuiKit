//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/12/23.
//

import Foundation

public struct SuiObjectInfo {
    public let suiObjectRef: SuiObjectRef
    public let type: String
    public let owner: ObjectOwner
    public let previousTransaction: TransactionDigest
}

public struct ObjectOwner {
    public let addressOwner: AddressOwner
    public let objectOwner: ObjectOwnerAddress?
    public let shared: Shared?
}

public struct AddressOwner {
    public let addressOwner: SuiAddress
}

public struct ObjectOwnerAddress {
    public let objectOwner: SuiAddress
}

public struct Shared {
    public let shared: InitialSharedVersion
}

public struct InitialSharedVersion {
    public let initialSharedVersion: Int
}
