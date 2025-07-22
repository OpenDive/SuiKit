//
//  RawData.swift
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

/// `RawData` represents the types of raw data that can be processed or generated.
///
/// This enum allows for either a `MoveObjectRaw` or `PackageRaw` data type, capturing
/// the raw information for either a Move object or a package object.
public enum RawData: Equatable {
    /// Represents raw data for a Move object. The associated value is a `MoveObjectRaw` containing the Move object's raw data.
    case moveObject(MoveObjectRaw)

    /// Represents raw data for a package object. The associated value is a `PackageRaw` containing the package object's raw data.
    case packageObject(PackageRaw)

    public init(graphql: TryGetPastObjectQuery.Data.Object.AsMoveObject, version: String) {
        self = .moveObject(
            MoveObjectRaw(
                bcsBytes: JSON(graphql.ifShowBcs!.contents!.bcs).stringValue,
                hasPublicTransfer: graphql.ifShowBcs!.hasPublicTransfer,
                type: graphql.ifShowBcs!.contents!.type.repr,
                version: version
            )
        )
    }

    public init(graphql: GetOwnedObjectsQuery.Data.Address.Objects.Node, version: String) {
        self = .moveObject(
            MoveObjectRaw(
                bcsBytes: JSON(graphql.contents!.ifShowBcs!.bcs).stringValue,
                hasPublicTransfer: graphql.hasPublicTransfer!,
                type: graphql.contents!.ifShowBcs!.type.repr,
                version: version
            )
        )
    }

    public init(graphql: MultiGetObjectsQuery.Data.Objects.Node, version: String) {
        self = .moveObject(
            MoveObjectRaw(
                bcsBytes: JSON(graphql.asMoveObject!.ifShowBcs!.contents!.bcs).stringValue,
                hasPublicTransfer: graphql.asMoveObject!.ifShowBcs!.hasPublicTransfer,
                type: graphql.asMoveObject!.ifShowBcs!.contents!.type.repr,
                version: version
            )
        )
    }

    public init(graphql: GetObjectQuery.Data.Object, version: String) {
        self = .moveObject(
            MoveObjectRaw(
                bcsBytes: JSON(graphql.asMoveObject!.ifShowBcs!.contents!.bcs).stringValue,
                hasPublicTransfer: graphql.asMoveObject!.ifShowBcs!.hasPublicTransfer,
                type: graphql.asMoveObject!.ifShowBcs!.contents!.type.repr,
                version: version
            )
        )
    }

    /// Parses a `JSON` object to determine the type of raw data it contains and returns a corresponding `RawData` instance.
    ///
    /// - Parameters:
    ///   - input: The JSON object containing the raw data information.
    /// - Returns: A `RawData` instance if the parsing is successful; otherwise, returns `nil`.
    ///
    /// This method will inspect the `dataType` key in the provided JSON to determine whether the data should be parsed as
    /// a `MoveObjectRaw` or a `PackageRaw`. Additional processing is done for each type to properly populate their respective fields.
    public static func parseJSON(_ input: JSON) -> RawData? {
        switch input["dataType"].stringValue {
        case "moveObject":
            return .moveObject(
                MoveObjectRaw(
                    bcsBytes: input["bcsBytes"].stringValue,
                    hasPublicTransfer: input["hasPublicTransfer"].boolValue,
                    type: input["type"].stringValue,
                    version: "\(input["version"].intValue)"
                )
            )
        case "packageObject":
            var linkageTable: [String: UpgradeInfo] = [:]
            var moduleMap: [String: String] = [:]

            for (linkKey, linkValue) in input["linkageTable"].dictionaryValue {
                linkageTable[linkKey] = UpgradeInfo.parseJSON(linkValue)
            }

            for (moduleKey, moduleValue) in input["moduleMap"].dictionaryValue {
                moduleMap[moduleKey] = moduleValue.stringValue
            }

            return .packageObject(
                PackageRaw(
                    id: input["id"].stringValue,
                    linkageTable: linkageTable,
                    moduleMap: moduleMap,
                    typeOriginTable: input["typeOriginTable"].arrayValue.map { TypeOrigin.parseJSON($0) },
                    version: input["version"].stringValue
                )
            )
        default:
            return nil
        }
    }
}
