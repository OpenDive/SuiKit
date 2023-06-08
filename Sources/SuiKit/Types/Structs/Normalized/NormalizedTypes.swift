//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/30/23.
//

import Foundation

public enum SuiMoveVisibility: String, Codable {
    case Private
    case Public
    case Friend
}

public struct SuiMoveNormalizedTypeParameterType: Codable {
    public let TypeParameter: Int
}

public struct SuiMoveNormalizedStructType: Codable {
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

public indirect enum SuiMoveNormalizedType: Codable {
    case string(String)
    case suiMoveNormalizedTypeParameterType(SuiMoveNormalizedTypeParameterType)
    case reference(SuiMoveNormalizedType)
    case mutableReference(SuiMoveNormalizedType)
    case vector(SuiMoveNormalizedType)
    case suiMoveNormalizedStructType(SuiMoveNormalizedStructType)
    
    enum CodingKeys: String, CodingKey {
        case string
        case suiMoveNormalizedTypeParameterType = "SuiMoveNormalizedTypeParameterType"
        case reference = "Reference"
        case mutableReference = "MutableReference"
        case vector = "Vector"
        case suiMoveNormalizedStructType = "SuiMoveNormalizedStructType"
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
    public let structs: [SuiMoveNormalizedStruct]
    public let exposedFunctions: [SuiMoveNormalizedFunction]
}
