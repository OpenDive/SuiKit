//
//  File.swift
//
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation
import AnyCodable
import SwiftyJSON

public enum TransactionArgumentName: String {
    case gasCoin = "GasCoin"
    case input = "Input"
    case result = "Result"
    case nestedResult = "NestedResult"
}

public enum TransactionArgument: KeyProtocol {
    case gasCoin
    case input(TransactionBlockInput)
    case result(Result)
    case nestedResult(NestedResult)

    public var kind: TransactionArgumentName {
        switch self {
        case .gasCoin:
            return .gasCoin
        case .input:
            return .input
        case .result:
            return .result
        case .nestedResult:
            return .nestedResult
        }
    }

    public static func fromJSON(_ input: JSON) -> TransactionArgument? {
        if input["Input"].exists() {
            return .input(TransactionBlockInput(index: input["Input"].uInt16Value))
        }
        if input["GasCoin"].exists() {
            return .gasCoin
        }
        if input["Result"].exists() {
            return .result(Result(index: input["Result"].uInt16Value))
        }
        if input["NestedResult"].exists() {
            let nestedResult = input["NestedResult"].arrayValue
            return .nestedResult(
                NestedResult(
                    index: nestedResult[0].uInt16Value,
                    resultIndex: nestedResult[1].uInt16Value
                )
            )
        }
        return nil
    }

    public func encodeInput(objects: inout [ObjectsToResolve], inputs: inout [TransactionBlockInput]) throws {
        switch self {
        case .input(let transactionBlockInput):
            try self.encodeInput(with: &(inputs[Int(transactionBlockInput.index)]), objects: &objects)
        default:
            return
        }
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .gasCoin:
            try Serializer.u8(serializer, UInt8(0))
        case .input(let transactionBlockInput):
            try Serializer.u8(serializer, UInt8(1))
            try Serializer._struct(serializer, value: transactionBlockInput)
        case .result(let result):
            try Serializer.u8(serializer, UInt8(2))
            try Serializer._struct(serializer, value: result)
        case .nestedResult(let nestedResult):
            try Serializer.u8(serializer, UInt8(3))
            try Serializer._struct(serializer, value: nestedResult)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionArgument {
        let type = try Deserializer.u8(deserializer)
        
        switch type {
        case 0:
            return TransactionArgument.input(try Deserializer._struct(deserializer))
        case 1:
            return TransactionArgument.gasCoin
        case 2:
            return TransactionArgument.result(try Deserializer._struct(deserializer))
        case 3:
            return TransactionArgument.nestedResult(try Deserializer._struct(deserializer))
        default:
            throw SuiError.notImplemented
        }
    }

    private func encodeInput(
        with input: inout TransactionBlockInput,
        objects: inout [ObjectsToResolve]
    ) throws {
        guard let value = input.value, let type = input.type else { throw SuiError.notImplemented }

        switch value {
        case .callArg:
            return
        case .string(let str):
            switch type {
            case .object:
                objects.append(
                    ObjectsToResolve(id: str, input: input, normalizedType: nil)
                )
            default:
                input.value = .callArg(
                    Input(
                        type: .pure(
                            Inputs.pure(json: value)
                        )
                    )
                )
            }
        default:
            switch type {
            case .pure:
                input.value = .callArg(
                    Input(type: .pure(Inputs.pure(json: value)))
                )
            case .object:
                throw SuiError.notImplemented
            }
        }
    }
}
