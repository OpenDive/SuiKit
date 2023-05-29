//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation

public enum TransactionResult {
    case transactionArgument(TransactionArgument)
    case transactionArgumentArray([TransactionArgument])
}

public struct TransactionBlockFunctions {
//    public static func createTransactionResult(index: Int) -> TransactionResult {
//        func nestedResultFor(index: Int, resultIndex: Int, nestedResult: [TransactionArgument]) -> TransactionArgument {
//            var changedNestedResult = nestedResult
//            if nestedResult.indices.contains(resultIndex) {
//                changedNestedResult[resultIndex] = TransactionArgument.nestedResult(NestedResult(kind: "NestedResult", index: index, resultIndex: resultIndex))
//                return changedNestedResult[resultIndex]
//            }
//            return nestedResult[resultIndex]
//        }
//
//        var baseResult = TransactionResult.transactionArgument(TransactionArgument.result(Result(kind: "Result", index: index)))
//        var nestedResult = TransactionResult.transactionArgumentArray([])
//    }
}
