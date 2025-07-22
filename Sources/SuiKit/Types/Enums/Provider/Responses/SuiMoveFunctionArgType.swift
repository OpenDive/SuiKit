//
//  SuiMoveFunctionArgType.swift
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

/// `SuiMoveFunctionArgType` represents the type of an argument in a Move function.
///
/// - `pure`: The argument is a pure value, meaning it doesn't involve any object references.
/// - `object`: The argument is an object, and its kind (immutable reference, mutable reference, or by value) is specified.
public enum SuiMoveFunctionArgType: Equatable {
    /// The argument is a pure value and doesn't involve any object references.
    case pure

    /// The argument is an object. The kind of the object (immutable/mutable reference or by value) is specified.
    case object(ObjectValueKind)

    public init(graphql: GetMoveFunctionArgTypesQuery.Data.Object.AsMovePackage.Module.Function.Parameter) {
        self = Self.fromHashable(hash: graphql.signature)
    }

    public init(graphql: RPC_MOVE_STRUCT_FIELDS.Field.Type_SelectionSet) {
        self = Self.fromHashable(hash: graphql.signature)
    }

    private static func fromHashable(hash: AnyHashable) -> SuiMoveFunctionArgType {
        let jsonGraphQL = JSON(hash)

        if !(jsonGraphQL["body"]["datatype"].exists()) {
            return .pure
        }

        if jsonGraphQL["ref"].stringValue == "&" {
            return .object(.byImmutableReference)
        }

        if jsonGraphQL["ref"].stringValue == "&mut" {
            return .object(.byMutableReference)
        }

        return .object(.byValue)
    }
}
