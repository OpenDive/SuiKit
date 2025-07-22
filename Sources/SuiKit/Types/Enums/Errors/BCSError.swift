//
//  BCSError.swift
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

/// `BCSError` represents a set of errors specific to operations within the BCS (Binary Canonical Serialization) domain.
public enum BCSError: Error, Equatable {
    /// Indicates that an unexpected value was encountered during serialization or deserialization. The associated value provides details.
    case unexpectedValue(value: String)

    /// Indicates that a failure occurred while converting a string to data. The associated value specifies the string that caused the failure.
    case stringToDataFailure(value: String)

    /// Indicates that a failure occurred while converting a string to UInt256. The associated value specifies the string that caused the failure.
    case stringToUInt256Failure(value: String)

    /// Indicates that an unexpectedly large ULEB128 value was encountered. The associated value specifies the string representation of the value.
    case unexpectedLargeULEB128Value(value: String)

    /// Indicates that an unexpected end of input occurred when a certain type of data was expected. It takes the expected and the found type as associated values.
    case unexpectedEndOfInput(requested: String, found: String)

    /// Indicates that an invalid data value was encountered. The supported type for the operation is provided as an associated value.
    case invalidDataValue(supportedType: String)

    /// Indicates that a particular element does not conform to the expected protocol. The type of the expected protocol is provided as an associated value.
    case doesNotConformTo(protocolType: String)

    /// Indicates that the length of the provided data is invalid.
    case invalidLength

    case customError(String)
}
