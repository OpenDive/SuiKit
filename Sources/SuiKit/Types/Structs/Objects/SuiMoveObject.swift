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

public enum SuiParsedData {
    case moveObject(MoveObject)
    case movePackage(MovePackage)

    public static func parseJSON(_ input: JSON) -> SuiParsedData? {
        switch input["dataType"].stringValue {
        case "moveObject":
            return .moveObject(
                MoveObject(
                    fields: MoveStruct.parseJSON(input["fields"]),
                    hasPublicTransfer: input["hasPublicTransfer"].boolValue,
                    type: input["type"].stringValue
                )
            )
        case "movePackage":
            return .movePackage(MovePackage.parseJSON(input["dissassembled"]))
        default:
            return nil
        }
    }
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

public enum MoveStruct {
    case fieldArray([MoveValue])
    case fieldType(MoveFieldType)
    case fieldMap([String: MoveValue])

    public static func parseJSON(_ input: JSON) -> MoveStruct? {
        if !(input["fields"].dictionaryValue.isEmpty) {
            var fieldsMap: [String: MoveValue] = [:]
            for (fieldKey, fieldValue) in input["fields"].dictionaryValue {
                fieldsMap[fieldKey] = MoveValue.parseJSON(fieldValue)
            }
            return .fieldMap(fieldsMap)
        }

        if let array = input["fields"].array {
            return .fieldArray(array.map { MoveValue.parseJSON($0) })
        }

        if input["type"].exists() {
            return .fieldType(MoveFieldType(input: input))
        }

        return nil
    }
}

public enum MoveValue {
    case number(Int)
    case boolean(Bool)
    case string(String)
    case moveValues([MoveValue])
    case id(MoveValueId)
    case moveStruct(MoveStruct)
    case null

    public static func parseJSON(_ input: JSON) -> MoveValue {
        if let number = input.int {
            return .number(number)
        }

        if let bool = input.bool {
            return .boolean(bool)
        }

        if let string = input.string {
            return .string(string)
        }

        if let array = input.array {
            return .moveValues(array.map { MoveValue.parseJSON($0) })
        }

        if input["id"].exists() {
            return .id(MoveValueId(input: input["id"]))
        }

        if let structure = MoveStruct.parseJSON(input) {
            return .moveStruct(structure)
        }

        return .null
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

public enum RawData {
    case moveObject(MoveObjectRaw)
    case packageObject(PackageRaw)

    public static func parseJSON(_ input: JSON) -> RawData? {
        switch input["dataType"].stringValue {
        case "moveObject":
            return .moveObject(
                MoveObjectRaw(
                    bcsBytes: input["bcsBytes"].stringValue,
                    hasPublicTransfer: input["hasPublicTransfer"].boolValue,
                    type: input["type"].stringValue,
                    version: "\(input["version"].intValue)"
                )
            )
        case "packageObject":
            var linkageTable: [String: UpgradeInfo] = [:]
            var moduleMap: [String: String] = [:]

            for (linkKey, linkValue) in input["linkageTable"].dictionaryValue {
                linkageTable[linkKey] = UpgradeInfo.parseJSON(linkValue)
            }

            for (moduleKey, moduleValue) in input["moduleMap"].dictionaryValue {
                moduleMap[moduleKey] = moduleValue.stringValue
            }

            return .packageObject(
                PackageRaw(
                    id: input["id"].stringValue,
                    linkageTable: linkageTable,
                    moduleMap: moduleMap,
                    typeOriginTable: input["typeOriginTable"].arrayValue.map { TypeOrigin.parseJSON($0) },
                    version: input["version"].stringValue
                )
            )
        default:
            return nil
        }
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
