//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public struct DevInspectResults {
    public var effects: TransactionEffects
    public var results: [ExecutionResultType]?
    public var error: String?
    public var events: [SuiEvent]

    public init?(input: JSON) {
        guard let effects = TransactionEffects(input: input["effects"]) else { return nil }
        self.effects = effects
        self.error = input["error"].string
        self.events = input["events"].arrayValue.compactMap { SuiEvent(input: $0) }
        self.results = input["results"].arrayValue.compactMap { ExecutionResultType(input: $0) }
    }
}

public struct ExecutionResultType {
    public var mutableReferenceOutputs: [MutableReferenceOutputType]?
    public var returnValues: [ReturnValueType]?

    public init?(input: JSON) {
        self.returnValues = []
        self.mutableReferenceOutputs = []

        var argument: SuiMoveNormalizedStructType? = nil
        var valueArray: [UInt8]? = nil
        var name: String? = nil
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
            var returnUInt8Array: [UInt8]? = nil
            var returnName: SuiMoveNormalizedStructType? = nil
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
