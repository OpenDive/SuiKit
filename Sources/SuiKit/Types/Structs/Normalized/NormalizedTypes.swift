//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/30/23.
//

import Foundation
import SwiftyJSON

public enum SuiMoveVisibility: String, Codable {
    case Private
    case Public
    case Friend
    
    public static func decodeVisibility(_ data: JSON) throws -> SuiMoveVisibility {
        switch data.stringValue {
        case "Private": return .Private
        case "Public": return .Public
        case "Friend": return .Friend
        default: throw SuiError.notImplemented
        }
    }
}

public struct SuiMoveNormalizedTypeParameterType: Codable {
    public let TypeParameter: Int
}

public struct SuiMoveNormalizedStructType: Codable, Equatable {
    public let address: String
    public let module: String
    public let name: String
    public let typeArguments: [SuiMoveNormalizedType]
}

public struct SuiMoveStructTypeParameter: Codable {
    public let constraints: SuiMoveAbilitySet
    public let isPhantom: Bool
}

public struct SuiMoveAbilitySet: Codable {
    public let abilities: [String]
}

public struct SuiMoveNormalizedField: Codable {
    public let name: String
    public let type: SuiMoveNormalizedType
}

public struct SuiMoveNormalizedStruct: Codable {
    public let abilities: SuiMoveAbilitySet
    public let typeParameters: [SuiMoveStructTypeParameter]
    public let fields: [SuiMoveNormalizedField]
}

public indirect enum SuiMoveNormalizedType: Codable, Equatable {
    case bool
    case u8
    case u16
    case u32
    case u64
    case u128
    case u256
    case address
    case signer
    case typeParameter(TypeParameter)
    case reference(SuiMoveNormalizedType)
    case mutableReference(SuiMoveNormalizedType)
    case vector(SuiMoveNormalizedType)
    case structure(SuiMoveNormalizedStructType)
    
    public struct TypeParameter: Codable, Equatable {
        var typeParameter: UInt16
        
        enum CodingKeys: String, CodingKey {
            case typeParameter = "TypeParameter"
        }
    }
    
    public var type: String {
        switch self {
        case .bool:
            return "Bool"
        case .u8:
            return "U8"
        case .u16:
            return "U16"
        case .u32:
            return "U32"
        case .u64:
            return "U64"
        case .u128:
            return "U128"
        case .u256:
            return "U256"
        case .address:
            return "Address"
        case .signer:
            return "Signer"
        case .typeParameter:
            return "TypeParameter"
        case .reference:
            return "Reference"
        case .mutableReference:
            return "MutableReference"
        case .vector:
            return "Vector"
        case .structure:
            return "Structure"
        }
    }
    
    public static func decodeNormalizedType(_ data: JSON) throws -> SuiMoveNormalizedType {
        switch data.stringValue {
        case "Bool":
            return .bool
        case "U8":
            return .u8
        case "U16":
            return .u16
        case "U32":
            return .u32
        case "U64":
            return .u64
        case "U128":
            return .u128
        case "U256":
            return .u256
        case "Address":
            return .address
        case "Signer":
            return .signer
        default:
            if data["Struct"].exists() {
                let structObj = data["Struct"]
                return .structure(
                    SuiMoveNormalizedStructType(
                        address: structObj["address"].stringValue,
                        module: structObj["module"].stringValue,
                        name: structObj["name"].stringValue,
                        typeArguments: try structObj["typeArguments"].arrayValue.map {
                            try decodeNormalizedType($0)
                        }
                    )
                )
            }
            if data["Vector"].exists() {
                return .vector(try decodeNormalizedType(data["Vector"]))
            }
            if data["TypeParameter"].exists() {
                return .typeParameter(
                    TypeParameter(
                        typeParameter: UInt16(data["TypeParameter"].int16Value)
                    )
                )
            }
            if data["Reference"].exists() {
                return .reference(try decodeNormalizedType(data["Reference"]))
            }
            if data["MutableReference"].exists() {
                return .mutableReference(try decodeNormalizedType(data["MutableReference"]))
            }
            throw SuiError.notImplemented
        }
    }
}

public struct SuiMoveModuleId: Codable {
    public let address: String
    public let name: String
}

public struct SuiMoveNormalizedFunction: Codable {
    public let visibility: SuiMoveVisibility
    public let isEntry: Bool
    public let typeParameters: [SuiMoveAbilitySet]
    public let parameters: [SuiMoveNormalizedType]
    public let returnValues: [SuiMoveNormalizedType]
    
    enum CodingKeys: String, CodingKey {
        case visibility
        case isEntry
        case typeParameters
        case parameters
        case returnValues = "return"
    }
}

public struct SuiMoveNormalizedModule: Codable {
    public let fileFormatVersion: Int
    public let address: String
    public let name: String
    public let friends: [SuiMoveModuleId]
    public let structs: [String: SuiMoveNormalizedStruct]
    public let exposedFunctions: [String: SuiMoveNormalizedFunction]
}

public typealias SuiMoveNormalizedModules = [String: SuiMoveNormalizedModule]
