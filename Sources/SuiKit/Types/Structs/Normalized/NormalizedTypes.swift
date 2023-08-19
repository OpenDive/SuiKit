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
    
    public static func parseJSON(_ data: JSON) -> SuiMoveVisibility? {
        switch data.stringValue {
        case "Private": return .Private
        case "Public": return .Public
        case "Friend": return .Friend
        default: return nil
        }
    }
}

public struct SuiMoveNormalizedTypeParameterType {
    public let TypeParameter: Int
}

public struct SuiMoveNormalizedStructType: Equatable, KeyProtocol, CustomStringConvertible {
    public let address: AccountAddress
    public let module: String
    public let name: String
    public let typeArguments: [SuiMoveNormalizedType]

    public var description: String {
        "\(self.address.hex())::\(self.module)::\(self.name)"
    }
    
    public func isSameStruct(_ rhs: any ResolvedProtocol) -> Bool {
        return
            self.address.hex() == rhs.address &&
            self.module == rhs.module &&
            self.name == rhs.name
    }
    
    public init(
        address: AccountAddress,
        module: String,
        name: String,
        typeArguments: [SuiMoveNormalizedType]
    ) {
        self.address = address
        self.module = module
        self.name = name
        self.typeArguments = typeArguments
    }

    public init(input: String) throws {
        let typeTag = try StructTag.fromStr(input)
        self.address = typeTag.value.address
        self.module = typeTag.value.module
        self.name = typeTag.value.name
        self.typeArguments = []
    }
    
    public init?(input: JSON) {
        guard let address = try? AccountAddress.fromHex(input["package"].stringValue) else { return nil }
        self.address = address
        self.module = input["module"].stringValue
        self.name = input["function"].stringValue
        self.typeArguments = input["arguments"].arrayValue.compactMap { SuiMoveNormalizedType.parseJSON($0) }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.address)
        try Serializer.str(serializer, self.module)
        try Serializer.str(serializer, self.name)
        if !self.typeArguments.isEmpty { try serializer.sequence(self.typeArguments, Serializer._struct) }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiMoveNormalizedStructType {
        return SuiMoveNormalizedStructType(
            address: try Deserializer._struct(deserializer),
            module: try Deserializer.string(deserializer),
            name: try Deserializer.string(deserializer),
            typeArguments: (try? deserializer.sequence(valueDecoder: Deserializer._struct)) ?? []
        )
    }
}

public struct SuiMoveStructTypeParameter {
    public let constraints: SuiMoveAbilitySet
    public let isPhantom: Bool
}

public struct SuiMoveAbilitySet {
    public let abilities: [String]

    public init(abilities: [String]) {
        self.abilities = abilities
    }

    public init(input: JSON) {
        self.abilities = input["abilities"].arrayValue.map { $0.stringValue }
    }
}

public struct SuiMoveNormalizedField {
    public let name: String
    public let type: SuiMoveNormalizedType
}

public struct SuiMoveNormalizedStruct {
    public let abilities: SuiMoveAbilitySet
    public let typeParameters: [SuiMoveStructTypeParameter]
    public let fields: [SuiMoveNormalizedField]

    public init(
        abilities: SuiMoveAbilitySet,
        typeParameters: [SuiMoveStructTypeParameter],
        fields: [SuiMoveNormalizedField]
    ) {
        self.abilities = abilities
        self.typeParameters = typeParameters
        self.fields = fields
    }

    public init?(input: JSON) {
        let typeParameters = input["typeParameters"].arrayValue
        let fields = input["fields"].arrayValue
        self.abilities = SuiMoveAbilitySet(input: input["abilities"])
        self.typeParameters = typeParameters.map {
            SuiMoveStructTypeParameter(
                constraints: SuiMoveAbilitySet(
                    abilities: $0["isPhantom"]["abilities"].arrayValue.map { $0.stringValue }
                ),
                isPhantom: $0["isPhantom"].boolValue
            )
        }
        var fieldsOutput: [SuiMoveNormalizedField] = []
        for field in fields {
            guard let type = SuiMoveNormalizedType.parseJSON(field["type"]) else { return nil }
            fieldsOutput.append(SuiMoveNormalizedField(
                name: field["name"].stringValue,
                type: type
            ))
        }
        self.fields = fieldsOutput
    }
}

public struct TypeParameter: Equatable, KeyProtocol {
    var typeParameter: UInt16
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u16(serializer, self.typeParameter)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TypeParameter {
        return TypeParameter(typeParameter: try Deserializer.u16(deserializer))
    }
}

public indirect enum SuiMoveNormalizedType: Equatable, KeyProtocol {
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
    
    public func getPureSerializationType(_ argVal: SuiJsonValue) throws -> String? {
        switch self {
        case .bool:
            return self.kind.lowercased()
        case .u8, .u16, .u32, .u64, .u128, .u256:
            return self.kind.lowercased()
        case .address, .signer:
            return self.kind.lowercased()
        case .vector(let normalizedTypeVector):
            if argVal.kind == .string, normalizedTypeVector.kind == "U8" {
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
    
    public func extractMutableReference() -> SuiMoveNormalizedType? {
        switch self {
        case .mutableReference(let suiMoveNormalizedType):
            return suiMoveNormalizedType
        default:
            return nil
        }
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
    
    public var kind: String {
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
    
    public static func parseJSON(_ data: JSON) -> SuiMoveNormalizedType? {
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
                guard let structure = SuiMoveNormalizedStructType(input: data["Struct"]) else { return nil }
                return .structure(
                    structure
                )
            }
            if data["Vector"].exists() {
                guard let vector = parseJSON(data["Vector"]) else { return nil }
                return .vector(vector)
            }
            if data["TypeParameter"].exists() {
                return .typeParameter(
                    TypeParameter(
                        typeParameter: UInt16(data["TypeParameter"].int16Value)
                    )
                )
            }
            if data["MutableReference"].exists() {
                guard let mutableReference = parseJSON(data["MutableReference"]) else { return nil }
                return .mutableReference(mutableReference)
            }
            if data["Reference"].exists() {
                guard let reference = parseJSON(data["Reference"]) else { return nil }
                return .reference(reference)
            }
            return nil
        }
    }
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .bool:
            try Serializer.u8(serializer, UInt8(0))
        case .u8:
            try Serializer.u8(serializer, UInt8(1))
        case .u16:
            try Serializer.u8(serializer, UInt8(2))
        case .u32:
            try Serializer.u8(serializer, UInt8(3))
        case .u64:
            try Serializer.u8(serializer, UInt8(4))
        case .u128:
            try Serializer.u8(serializer, UInt8(5))
        case .u256:
            try Serializer.u8(serializer, UInt8(6))
        case .address:
            try Serializer.u8(serializer, UInt8(7))
        case .signer:
            try Serializer.u8(serializer, UInt8(8))
        case .typeParameter(let typeParameter):
            try Serializer.u8(serializer, UInt8(9))
            try Serializer._struct(serializer, value: typeParameter)
        case .reference(let suiMoveNormalizedType):
            try Serializer.u8(serializer, UInt8(10))
            try Serializer._struct(serializer, value: suiMoveNormalizedType)
        case .mutableReference(let suiMoveNormalizedType):
            try Serializer.u8(serializer, UInt8(11))
            try Serializer._struct(serializer, value: suiMoveNormalizedType)
        case .vector(let suiMoveNormalizedType):
            try Serializer.u8(serializer, UInt8(12))
            try Serializer._struct(serializer, value: suiMoveNormalizedType)
        case .structure(let suiMoveNormalizedStructType):
            try Serializer.u8(serializer, UInt8(13))
            try Serializer._struct(serializer, value: suiMoveNormalizedStructType)
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SuiMoveNormalizedType {
        let value = try Deserializer.u8(deserializer)
        
        switch value {
        case 0:
            return .bool
        case 1:
            return .u8
        case 2:
            return .u16
        case 3:
            return .u32
        case 4:
            return .u64
        case 5:
            return .u128
        case 6:
            return .u256
        case 7:
            return .address
        case 8:
            return .signer
        case 9:
            return .typeParameter(try Deserializer._struct(deserializer))
        case 10:
            return .reference(try Deserializer._struct(deserializer))
        case 11:
            return .mutableReference(try Deserializer._struct(deserializer))
        case 12:
            return .vector(try Deserializer._struct(deserializer))
        case 13:
            return .structure(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
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

    public init(
        visibility: SuiMoveVisibility,
        isEntry: Bool,
        typeParameters: [SuiMoveAbilitySet],
        parameters: [SuiMoveNormalizedType],
        returnValues: [SuiMoveNormalizedType]
    ) {
        self.visibility = visibility
        self.isEntry = isEntry
        self.typeParameters = typeParameters
        self.parameters = parameters
        self.returnValues = returnValues
    }

    public init?(input: JSON) {
        guard let visibility = SuiMoveVisibility.parseJSON(input["visibility"]) else { return nil }
        self.visibility = visibility
        self.isEntry = input["isEntry"].boolValue
        self.typeParameters = input["typeParameters"].arrayValue.map { SuiMoveAbilitySet(input: $0) }
        self.parameters = input["parameters"].arrayValue.compactMap { SuiMoveNormalizedType.parseJSON($0) }
        self.returnValues = input["returnValues"].arrayValue.compactMap { SuiMoveNormalizedType.parseJSON($0) }
    }

    public func hasTxContext() -> Bool {
        guard !(parameters.isEmpty) else { return false }
        let possiblyTxContext = parameters.last!
        guard let structTag = possiblyTxContext.extractStructTag() else { return false }
        
        return
            structTag.address.hex() == "0x2" &&
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
    
    public init?(input: JSON) {
        var structs: [String: SuiMoveNormalizedStruct] = [:]
        var exposedFunctions: [String: SuiMoveNormalizedFunction] = [:]
        for (structKey, structValue) in input["structs"].dictionaryValue {
            structs[structKey] = SuiMoveNormalizedStruct(input: structValue)
        }
        for (exposedKey, exposedValue) in input["exposedFunctions"].dictionaryValue {
            exposedFunctions[exposedKey] = SuiMoveNormalizedFunction(input: exposedValue)
        }
        self.fileFormatVersion = input["fileFormatVersion"].intValue
        self.address = input["address"].stringValue
        self.name = input["name"].stringValue
        self.friends = input["friends"].arrayValue.map {
            SuiMoveModuleId(
                address: $0["address"].stringValue,
                name: $0["name"].stringValue
            )
        }
        self.structs = structs
        self.exposedFunctions = exposedFunctions
    }
}

public typealias SuiMoveNormalizedModules = [String: SuiMoveNormalizedModule]
