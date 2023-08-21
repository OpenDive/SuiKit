//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation
import SwiftyJSON

public typealias ObjectContentFields = [String: Any]

public struct SuiMoveObject {
    public let type: String
    public let fields: ObjectContentFields?
    public let hasPublicTransfer: Bool
}

public struct MoveObject {
    public var fields: MoveStruct?
    public var hasPublicTransfer: Bool
    public var type: String
}

public struct MovePackage {
    public var disassembled: [String: String]

    public static func parseJSON(_ input: JSON) -> MovePackage {
        var package: [String: String] = [:]
        for (key, value) in input.dictionaryValue {
            package[key] = value.stringValue
        }
        return MovePackage(disassembled: package)
    }
}

public struct MoveValueId {
    public var id: String

    public init(input: JSON) {
        self.id = input["id"].stringValue
    }
}

public struct MoveFieldType {
    public var fields: [String: MoveValue]
    public var type: String

    public init(input: JSON) {
        var fieldsOutput: [String: MoveValue] = [:]
        for (key, value) in input["fields"].dictionaryValue {
            fieldsOutput[key] = MoveValue.parseJSON(value)
        }
        self.fields = fieldsOutput
        self.type = input["type"].stringValue
    }
}

public struct MoveObjectRaw {
    public var bcsBytes: String
    public var hasPublicTransfer: Bool
    public var type: String
    public var version: String
}

public struct PackageRaw {
    public var id: String
    public var linkageTable: [String: UpgradeInfo]
    public var moduleMap: [String: String]
    public var typeOriginTable: [TypeOrigin]
    public var version: String
}

public struct UpgradeInfo {
    public var upgradedId: String
    public var upgradedVersion: String

    public static func parseJSON(_ input: JSON) -> UpgradeInfo {
        return UpgradeInfo(
            upgradedId: input["upgradedId"].stringValue,
            upgradedVersion: input["upgradedVersion"].stringValue
        )
    }
}

public struct TypeOrigin {
    public var moduleName: String
    public var packageName: String
    public var structName: String

    public static func parseJSON(_ input: JSON) -> TypeOrigin {
        return TypeOrigin(
            moduleName: input["moduleName"].stringValue,
            packageName: input["packageeName"].stringValue,
            structName: input["structName"].stringValue
        )
    }
}
