//
//  ResolvedConstants.swift
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

public struct ResolvedConstants {
    /// Represents the standard name for the `Option` struct.
    public static let stdOptionStructName = "Option"

    /// Represents the module name where the standard `Option` struct is declared.
    public static let stdOptionModuleName = "option"

    /// Represents the standard name for the `String` struct in UTF-8.
    public static let stdUtf8StructName = "String"

    /// Represents the module name where the standard UTF-8 `String` struct is declared.
    public static let stdUtf8ModuleName = "string"

    /// Represents the standard name for the `String` struct in ASCII.
    public static let stdAsciiStructName = "String"

    /// Represents the module name where the standard ASCII `String` struct is declared.
    public static let stdAsciiModuleName = "ascii"

    /// Represents the address associated with the SUI system.
    public static let suiSystemAddress = "0x3"

    /// Represents the address associated with the SUI framework.
    public static let suiFrameworkAddress = "0x2"

    /// Represents the address associated with the Move standard library.
    public static let moveStdlibAddress = "0x1"

    /// Represents the module name where the `object` is declared.
    public static let objectModuleName = "object"

    /// Represents the standard name for the `UID` struct.
    public static let uidStructName = "UID"

    /// Represents the standard name for the `ID` struct.
    public static let idStructName = "ID"

    /// Represents a string combining the SUI framework address and the standard SUI string.
    public static let suiTypeArg = "\(ResolvedConstants.suiFrameworkAddress)::sui::SUI"

    /// Represents a string that can be used to query validators event.
    public static let validatorsEventQuery = "\(ResolvedConstants.suiSystemAddress)::validator_set::ValidatorEpochInfoEventV2"

    /// Initializes a new instance of `ResolvedConstants`.
    /// As all properties are static constants, no parameters are needed and rarely this initializer will be used.
    public init() {}
}
