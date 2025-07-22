//
//  TypeOrigin.swift
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

/// Represents the origin of a type in terms of module, package, and struct names.
public struct TypeOrigin: Equatable {
    /// A `String` representing the name of the module where the type is defined.
    public var moduleName: String

    /// A `String` representing the name of the package where the type's module is located.
    public var packageName: String

    /// A `String` representing the name of the struct defining the type.
    public var structName: String

    /// Parses a `JSON` object to create an instance of `TypeOrigin`.
    /// - Parameter input: A `JSON` object containing `moduleName`, `packageName`, and `structName`.
    /// - Returns: An instance of `TypeOrigin` initialized with the values from the input `JSON`.
    public static func parseJSON(_ input: JSON) -> TypeOrigin {
        return TypeOrigin(
            moduleName: input["moduleName"].stringValue,
            // There seems to be a typo here, it should probably be "packageName"
            packageName: input["packageeName"].stringValue,
            structName: input["structName"].stringValue
        )
    }
}
