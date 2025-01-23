//
//  SuiObjectDataFilter.swift
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

/// `SuiObjectDataFilter` defines various filters that can be applied to object data within the Sui blockchain ecosystem.
///
/// The enum supports different types of data filters such as package, move module, object ID, etc.
/// It also provides compound filtering capabilities like `matchAll`, `matchAny`, and `matchNone`.
public enum SuiObjectDataFilter: Codable {
    /// Keys used for encoding and decoding the enum cases.
    private enum CodingKeys: String, CodingKey {
        case matchAll = "MatchAll"
        case matchAny = "MatchAny"
        case matchNone = "MatchNone"
        case package = "Package"
        case moveModule = "MoveModule"
        case structType = "StructType"
        case addressOwner = "AddressOwner"
        case objectOwner = "ObjectOwner"
        case objectId = "ObjectId"
        case objectIds = "ObjectIds"
        case version = "Version"
    }

    /// All filters in the array should match.
    case matchAll([SuiObjectDataFilter])

    /// Any filter in the array should match.
    case matchAny([SuiObjectDataFilter])

    /// None of the filters in the array should match.
    case matchNone([SuiObjectDataFilter])

    /// Filter object data by package ID.
    case package(String)

    /// Filter object data by characteristics of the Move module.
    case moveModule(MoveModuleFilter)

    /// Filter object data by the struct type.
    case structType(String)

    /// Filter object data by address owner.
    case addressOwner(String)

    /// Filter object data by object owner.
    case objectOwner(String)

    /// Filter object data by a specific object ID.
    case objectId(String)

    /// Filter object data by a list of object IDs.
    case objectIds([String])

    /// Filter object data by version.
    case version(String)

    /// Encode the enum into a container.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .matchAll(let array):
            try container.encode(array, forKey: .matchAll)
        case .matchAny(let array):
            try container.encode(array, forKey: .matchAny)
        case .matchNone(let array):
            try container.encode(array, forKey: .matchNone)
        case .package(let string):
            try container.encode(string, forKey: .package)
        case .moveModule(let moveModuleFilter):
            try container.encode(moveModuleFilter, forKey: .moveModule)
        case .structType(let string):
            try container.encode(string, forKey: .structType)
        case .addressOwner(let string):
            try container.encode(string, forKey: .addressOwner)
        case .objectOwner(let string):
            try container.encode(string, forKey: .objectOwner)
        case .objectId(let string):
            try container.encode(string, forKey: .objectId)
        case .objectIds(let array):
            try container.encode(array, forKey: .objectId)
        case .version(let string):
            try container.encode(string, forKey: .version)
        }
    }
}
