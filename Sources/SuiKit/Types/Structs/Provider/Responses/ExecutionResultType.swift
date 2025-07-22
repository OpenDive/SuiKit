//
//  ExecutionResultType.swift
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

/// Represents the type of execution result, which includes mutable reference outputs
/// and return values after the execution of a function or operation.
public struct ExecutionResultType {
    /// An optional array of `MutableReferenceOutputType` representing the mutable
    /// reference outputs obtained as a result of the execution. If `nil`, it may indicate
    /// that there were no mutable reference outputs produced during the execution.
    public var mutableReferenceOutputs: [MutableReferenceOutputType]?

    /// An optional array of `ReturnValueType` representing the return values obtained
    /// as a result of the execution. If `nil`, it may indicate that there were no return
    /// values produced during the execution.
    public var returnValues: [ReturnValueType]?

    public init?(input: JSON) {
        self.returnValues = []
        self.mutableReferenceOutputs = []

        var argument: SuiMoveNormalizedStructType?
        var valueArray: [UInt8]?
        var name: String?
        let mutable = input["mutableReferenceOutputs"].arrayValue
        for mutableValue in mutable {
            mutableValue.arrayValue.forEach { value in
                if let type = value.string {
                    if let argumentUnwrapped = try? SuiMoveNormalizedStructType(input: type) {
                        argument = argumentUnwrapped
                    } else {
                        name = type
                    }
                } else if let uInt8ArrayValue = value.array {
                    valueArray = uInt8ArrayValue.map { $0.uInt8Value }
                }
            }
            guard
                let argument,
                let valueArray,
                let name
            else {
                return nil
            }
            self.mutableReferenceOutputs?.append((argument, valueArray, name))
        }
        let returnValues = input["returnValues"].arrayValue
        for returnIteration in returnValues {
            var returnUInt8Array: [UInt8]?
            var returnName: SuiMoveNormalizedStructType?
            returnIteration.arrayValue.forEach { returnValue in
                if let uInt8ArrayValue = returnValue.array {
                    returnUInt8Array = uInt8ArrayValue.map { $0.uInt8Value }
                } else if let returnArgumentUnwrapped = try? SuiMoveNormalizedStructType(input: returnValue.stringValue) {
                    returnName = returnArgumentUnwrapped
                }
            }
            guard
                let returnUInt8Array,
                let returnName
            else {
                return nil
            }
            self.returnValues?.append((returnUInt8Array, returnName))
        }

        if self.mutableReferenceOutputs!.isEmpty || self.returnValues!.isEmpty {
            return nil
        }
    }
}
