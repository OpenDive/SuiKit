//
//  MovePackage.swift
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

/// Represents a Move Package in the Move programming language.
/// A Move Package is a container for Move Modules, where each module contains Move Scripts and Move Structs.
public struct MovePackage: Equatable {
    /// A dictionary where the key is a `String` representing the name of a module, script, or struct,
    /// and the value is a `String` representing the disassembled bytecode of that entity.
    public var disassembled: [String: String]

    /// Parses a `JSON` object to initialize a `MovePackage`.
    /// - Parameter input: A `JSON` object containing the Move Package data.
    /// - Returns: An instance of `MovePackage` initialized with the parsed data.
    public static func parseJSON(_ input: JSON) -> MovePackage {
        var package: [String: String] = [:]
        for (key, value) in input.dictionaryValue {
            package[key] = value.stringValue
        }
        return MovePackage(disassembled: package)
    }
}
