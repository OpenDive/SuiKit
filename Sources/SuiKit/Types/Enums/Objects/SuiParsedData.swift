//
//  SuiParsedData.swift
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

/// `SuiParsedData` represents the types of parsed data that can be encountered in the Sui blockchain ecosystem.
///
/// The enum handles two main types of parsed data: `MoveObject` and `MovePackage`, which represent
/// different kinds of data structures commonly used in Sui-related operations.
public enum SuiParsedData: Equatable {
    /// Represents a parsed Move object. The associated value is a `MoveObject` that holds the parsed fields and other relevant data for a Move object.
    case moveObject(MoveObject)

    /// Represents a parsed Move package. The associated value is a `MovePackage` containing the disassembled or decomposed package information.
    case movePackage(MovePackage)

    public init(graphql: TryGetPastObjectQuery.Data.Object.AsMoveObject) {
        let fields: [String: AnyHashable] = [
            "data": graphql.ifShowContent!.contents!.data,
            "layout": graphql.ifShowContent!.contents!.type.layout
        ]
        self = .moveObject(
            MoveObject(
                fields: JSON(fields),
                hasPublicTransfer: graphql.ifShowContent!.hasPublicTransfer,
                type: graphql.ifShowContent!.contents!.type.repr
            )
        )
    }

    public init(graphql: GetOwnedObjectsQuery.Data.Address.Objects.Node) {
        let fields: [String: AnyHashable] = [
            "data": graphql.contents!.ifShowContent!.data,
            "layout": graphql.contents!.ifShowContent!.type.layout!
        ]
        self = .moveObject(
            MoveObject(
                fields: JSON(fields),
                hasPublicTransfer: graphql.hasPublicTransfer!,
                type: graphql.contents!.ifShowContent!.type.repr
            )
        )
    }

    public init(graphql: MultiGetObjectsQuery.Data.Objects.Node) {
        let fields: [String: AnyHashable] = [
            "data": graphql.asMoveObject!.ifShowContent!.contents!.data,
            "layout": graphql.asMoveObject!.ifShowContent!.contents!.type.layout
        ]
        self = .moveObject(
            MoveObject(
                fields: JSON(fields),
                hasPublicTransfer: graphql.asMoveObject!.ifShowContent!.hasPublicTransfer,
                type: graphql.asMoveObject!.ifShowContent!.contents!.type.repr
            )
        )
    }

    public init(graphql: GetObjectQuery.Data.Object) {
        let fields: [String: AnyHashable] = [
            "data": graphql.asMoveObject!.ifShowContent!.contents!.data,
            "layout": graphql.asMoveObject!.ifShowContent!.contents!.type.layout
        ]
        self = .moveObject(
            MoveObject(
                fields: JSON(fields),
                hasPublicTransfer: graphql.asMoveObject!.ifShowContent!.hasPublicTransfer,
                type: graphql.asMoveObject!.ifShowContent!.contents!.type.repr
            )
        )
    }

    /// Parses a JSON object to determine the type of parsed data and returns an instance of `SuiParsedData`.
    ///
    /// - Parameters:
    ///   - input: The JSON object containing the parsed data information.
    /// - Returns: An instance of `SuiParsedData` if parsing is successful; otherwise, returns `nil`.
    ///
    /// This function reads the `dataType` key from the input JSON to decide whether the data should be interpreted as a `MoveObject` or a `MovePackage`.
    /// It then proceeds to create an instance of the corresponding type based on the additional information in the JSON object.
    public static func parseJSON(_ input: JSON) -> SuiParsedData? {
        switch input["dataType"].stringValue {
        case "moveObject":
            return .moveObject(
                MoveObject(
                    fields: input["fields"],
                    hasPublicTransfer: input["hasPublicTransfer"].boolValue,
                    type: input["type"].stringValue
                )
            )
        case "movePackage":
            return .movePackage(MovePackage.parseJSON(input["dissassembled"]))
        default:
            return nil
        }
    }
}
