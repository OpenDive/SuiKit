//
//  SuiMoveNormalizedModule.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftyJSON

/// Represents a normalized SuiMove Module, containing various details about the module including its address,
/// name, friend modules, structs, and exposed functions.
public struct SuiMoveNormalizedModule: Equatable {
    /// Specifies the file format version of the module.
    public let fileFormatVersion: Int

    /// The address where the module is located.
    public let address: String

    /// The name of the module.
    public let name: String

    /// An array of `SuiMoveModuleId` representing the friend modules of this module.
    public let friends: [SuiMoveModuleId]

    /// A dictionary containing the structs present in the module, where the key is the name of the struct and the value is an instance of `SuiMoveNormalizedStruct`.
    public let structs: [String: SuiMoveNormalizedStruct]

    /// A dictionary containing the exposed functions of the module, where the key is the name of the function and the value is an instance of `SuiMoveNormalizedFunction`.
    public let exposedFunctions: [String: SuiMoveNormalizedFunction]

    public init(graphql: GetNormalizedMoveModuleQuery.Data.Object.AsMovePackage.Module, package: String) {
        let module = graphql
        var structs: [String: SuiMoveNormalizedStruct] = [:]
        var exposedFunctions: [String: SuiMoveNormalizedFunction] = [:]

        if let structures = module.structs {
            for structure in structures.nodes {
                structs[structure.name] = SuiMoveNormalizedStruct(
                    structure: structure
                )
            }
        }

        if let functions = module.functions {
            for function in functions.filterUsable() {
                if let value = SuiMoveNormalizedFunction(function: function) {
                    exposedFunctions[function.name] = value
                }
            }
        }

        self.fileFormatVersion = module.fileFormatVersion
        self.address = package
        self.name = module.name
        self.friends = module.friends.nodes.map {
            SuiMoveModuleId(address: $0.package.address, name: $0.name)
        }
        self.structs = structs
        self.exposedFunctions = exposedFunctions
    }

    public init(graphql: GetNormalizedMoveModulesByPackageQuery.Data.Object.AsMovePackage.Modules.Node, package: String) {
        let module = graphql
        var structs: [String: SuiMoveNormalizedStruct] = [:]
        var exposedFunctions: [String: SuiMoveNormalizedFunction] = [:]

        if let structures = module.structs {
            for structure in structures.nodes {
                structs[structure.name] = SuiMoveNormalizedStruct(
                    structure: structure
                )
            }
        }

        if let functions = module.functions {
            for function in functions.filterUsable() {
                if let value = SuiMoveNormalizedFunction(function: function) {
                    exposedFunctions[function.name] = value
                }
            }
        }

        self.fileFormatVersion = module.fileFormatVersion
        self.address = package
        self.name = module.name
        self.friends = module.friends.nodes.map {
            SuiMoveModuleId(address: $0.package.address, name: $0.name)
        }
        self.structs = structs
        self.exposedFunctions = exposedFunctions
    }

    /// Initializes a new instance of `SuiMoveNormalizedModule` from a JSON representation.
    /// Returns `nil` if there is an issue with the JSON input.
    ///
    /// - Parameter input: A JSON representation of a `SuiMoveNormalizedModule`.
    public init?(input: JSON) {
        var structs: [String: SuiMoveNormalizedStruct] = [:]
        var exposedFunctions: [String: SuiMoveNormalizedFunction] = [:]

        for (structKey, structValue) in input["structs"].dictionaryValue {
            structs[structKey] = SuiMoveNormalizedStruct(input: structValue)
        }

        for (exposedKey, exposedValue) in input["exposedFunctions"].dictionaryValue {
            if
                (exposedValue["visibility"].stringValue == "Friend" || exposedValue["visibility"].stringValue == "Public") ||
                (exposedValue["isEntry"].boolValue) {
                exposedFunctions[exposedKey] = SuiMoveNormalizedFunction(input: exposedValue)
            }
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
