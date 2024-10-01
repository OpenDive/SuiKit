//
//  File.swift
//  
//
//  Created by Marcus Arnett on 1/17/24.
//

import Foundation

extension AnyHashable: @retroactive GraphQLOperationVariableValue {}
extension AnyHashable: @retroactive JSONDecodable {}
extension AnyHashable: @retroactive JSONEncodable {}
extension AnyHashable: @retroactive ScalarType, @retroactive OutputTypeConvertible, @retroactive AnyScalarType {
    public init(_jsonValue value: JSONValue) throws {
        self = value
    }
    
    public static var _asOutputType: ApolloAPI.Selection.Field.OutputType {
        .scalar(AnyHashable.self)
    }
    
    public var _jsonValue: ApolloAPI.JSONValue {
        self
    }
}
