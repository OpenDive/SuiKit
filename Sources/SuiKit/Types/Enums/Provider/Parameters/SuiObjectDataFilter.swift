//
//  SuiObjectDataFilter.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

public enum SuiObjectDataFilter: Codable {
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

    case matchAll([SuiObjectDataFilter])
    case matchAny([SuiObjectDataFilter])
    case matchNone([SuiObjectDataFilter])
    case package(String)
    case moveModule(MoveModuleFilter)
    case structType(String)
    case addressOwner(String)
    case objectOwner(String)
    case objectId(String)
    case objectIds([String])
    case version(String)

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
