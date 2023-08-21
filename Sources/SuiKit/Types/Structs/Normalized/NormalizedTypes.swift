//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/30/23.
//

import Foundation
import SwiftyJSON

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
        guard let rhsAddress = try? Inputs.normalizeSuiAddress(value: rhs.address) else { return false }
        return
            self.address.hex() == rhsAddress &&
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
        guard let address = try? AccountAddress.fromHex(input["address"].stringValue) else { return nil }
        self.address = address
        self.module = input["module"].stringValue
        self.name = input["name"].stringValue
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
            typeArguments: []
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

    public func hasTxContext() throws -> Bool {
        guard !(parameters.isEmpty) else { return false }
        let possiblyTxContext = parameters.last!
        guard let structTag = possiblyTxContext.extractStructTag() else { return false }
        
        return
            try structTag.address.hex() == Inputs.normalizeSuiAddress(value: "0x2") &&
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
