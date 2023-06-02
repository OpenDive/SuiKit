//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/30/23.
//

import Foundation

public struct SuiMoveNormalizedTypeParameterType {
    public let TypeParameter: Int
}

public struct SuiMoveNormalizedStructType {
    public let address: String
    public let module: String
    public let name: String
    public let typeArguments: [SuiMoveNormalizedType]
}

public indirect enum SuiMoveNormalizedType {
    case string(String)
    case suiMoveNormalizedTypeParameterType(SuiMoveNormalizedTypeParameterType)
    case reference(SuiMoveNormalizedType)
    case mutableReference(SuiMoveNormalizedType)
    case vector(SuiMoveNormalizedType)
    case suiMoveNormalizedStructType(SuiMoveNormalizedStructType)
}
