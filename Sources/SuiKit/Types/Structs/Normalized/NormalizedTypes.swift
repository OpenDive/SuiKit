//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/30/23.
//

import Foundation
import SwiftyJSON

public enum SuiMoveVisibility: String {
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

public struct SuiMoveNormalizedTypeParameterType {
    public let TypeParameter: Int
}

public struct SuiMoveNormalizedStructType: Equatable {
    public let address: String
    public let module: String
    public let name: String
    public let typeArguments: [SuiMoveNormalizedType]

    public func isSameStruct(_ rhs: any ResolvedProtocol) -> Bool {
        return
            self.address == rhs.address &&
            self.module == rhs.module &&
            self.name == rhs.name
    }
}

public struct SuiMoveStructTypeParameter {
    public let constraints: SuiMoveAbilitySet
    public let isPhantom: Bool
}

public struct SuiMoveAbilitySet {
    public let abilities: [String]
}

public struct SuiMoveNormalizedField {
    public let name: String
    public let type: SuiMoveNormalizedType
}

public struct SuiMoveNormalizedStruct {
    public let abilities: SuiMoveAbilitySet
    public let typeParameters: [SuiMoveStructTypeParameter]
    public let fields: [SuiMoveNormalizedField]
}

public indirect enum SuiMoveNormalizedType: Equatable {
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

    public func extractMutableReference() -> SuiMoveNormalizedType? {
        switch self {
        case .mutableReference(let suiMoveNormalizedType):
            return suiMoveNormalizedType
        default:
            return nil
        }
    }

    public func getPureSerializationType(_ argVal: SuiJsonValue) throws -> String? {
        switch self {
        case .bool:
            try self.expectType("boolean", argVal)
            return self.type.lowercased()
        case .u8, .u16, .u32, .u64, .u128, .u256:
            try self.expectType("number", argVal)
            return self.type.lowercased()
        case .address, .signer:
            try self.expectType("string", argVal)
            switch argVal {
            case .string(let str):
                guard self.isValidSuiAddress(str) else { throw SuiError.notImplemented }
            default:
                throw SuiError.notImplemented
            }
            return self.type.lowercased()
        case .vector(let normalizedTypeVector):
            if argVal.kind == .string, normalizedTypeVector.type == "U8" {
                return "string"
            }
            let innerType = try normalizedTypeVector.getPureSerializationType(argVal)
            guard innerType != nil else { return nil }
            return "vector<\(innerType!)>"
        case .structure(let normalizedStruct):
            if normalizedStruct.isSameStruct(ResolvedAsciiStr()) {
                return "string"
            }
            if normalizedStruct.isSameStruct(ResolvedUtf8Str()) {
                return "utf8string"
            }
            if normalizedStruct.isSameStruct(ResolvedSuiId()) {
                return "address"
            }
            if normalizedStruct.isSameStruct(ResolvedStdOption()) {
                guard !(normalizedStruct.typeArguments.isEmpty) else { throw SuiError.notImplemented }
                let optionToVec: SuiMoveNormalizedType = .vector(normalizedStruct.typeArguments[0])

                return try optionToVec.getPureSerializationType(argVal)
            }
        default:
            return nil
        }
        return nil
    }

    public func extractStructTag() -> SuiMoveNormalizedStructType? {
        switch self {
        case .reference(let suiMoveNormalizedType):
            switch suiMoveNormalizedType {
            case .structure(let structure):
                return structure
            default:
                return nil
            }
        case .mutableReference(let suiMoveNormalizedType):
            switch suiMoveNormalizedType {
            case .structure(let structure):
                return structure
            default:
                return nil
            }
        default:
            return nil
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

    private func expectType(_ typeName: String, _ argVal: SuiJsonValue) throws {
        if SuiJsonValueType(rawValue: typeName) == nil {
            throw SuiError.notImplemented
        }
        if (SuiJsonValueType(rawValue: typeName))! != argVal.kind {
            throw SuiError.notImplemented
        }
    }

    private func isValidSuiAddress(_ value: String) -> Bool {
        return isHex(value) && self.getHexByteLength(value) == 32
    }

    private func isHex(_ value: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(0x|0X)?[a-fA-F0-9]+$")
        let range = NSRange(location: 0, length: value.utf16.count)
        let match = regex.firstMatch(in: value, options: [], range: range)

        return match != nil && value.count % 2 == 0
    }

    private func getHexByteLength(_ value: String) -> Int {
        if value.hasPrefix("0x") || value.hasPrefix("0X") {
            return (value.count - 2) / 2
        } else {
            return value.count / 2
        }
    }
}

public struct SuiMoveModuleId {
    public let address: String
    public let name: String
}

public struct SuiMoveNormalizedFunction {
    public let visibility: SuiMoveVisibility
    public let isEntry: Bool
    public let typeParameters: [SuiMoveAbilitySet]
    public let parameters: [SuiMoveNormalizedType]
    public let returnValues: [SuiMoveNormalizedType]
    
    public func hasTxContext() -> Bool {
        guard !(parameters.isEmpty) else { return false }
        let possiblyTxContext = parameters.last!
        guard let structTag = possiblyTxContext.extractStructTag() else { return false }

        return
            structTag.address == "0x2" &&
            structTag.module == "tx_context" &&
            structTag.name == "TxContext"
    }
}

public struct SuiMoveNormalizedModule {
    public let fileFormatVersion: Int
    public let address: String
    public let name: String
    public let friends: [SuiMoveModuleId]
    public let structs: [String: SuiMoveNormalizedStruct]
    public let exposedFunctions: [String: SuiMoveNormalizedFunction]
}

public typealias SuiMoveNormalizedModules = [String: SuiMoveNormalizedModule]
