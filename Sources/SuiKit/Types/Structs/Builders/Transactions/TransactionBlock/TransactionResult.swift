//
//  TransactionResult.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

/// `TransactionResult` class encapsulates the results of a transaction.
/// It holds a main `transactionArgument` and a collection of `nestedResults`
/// representing the sub-results associated with the main transaction argument.
public class TransactionResult {
    /// Represents the main transaction argument which holds a result.
    let transactionArgument: TransactionArgument

    /// An array holding the nested results, each represented by a `TransactionArgument`.
    var nestedResults: [TransactionArgument]

    /// Initializes a new instance of `TransactionResult` with the specified index.
    ///
    /// - Parameter index: The index representing the position of the transaction argument.
    public init(index: UInt16) {
        self.transactionArgument = TransactionArgument.result(
            Result(index: index)
        )
        self.nestedResults = []
    }

    /// Retrieves the nested result for a given result index. If the nested result
    /// does not exist, it is created, appended to the `nestedResults` array,
    /// and then returned.
    ///
    /// - Parameter resultIndex: The index representing the position of the nested result.
    /// - Returns: A `TransactionArgument` representing the nested result
    ///            corresponding to the `resultIndex`, or `nil` if the main `transactionArgument`
    ///            is not of type `.result`.
    public func nestedResultFor(_ resultIndex: UInt16) -> TransactionArgument? {
        let index = Int(resultIndex)
        if let existingResult = nestedResults[safe: index] {
            return existingResult
        }
        if case .result(let result) = transactionArgument {
            let nestedResult = TransactionArgument.nestedResult(
                NestedResult(
                    index: result.index,
                    resultIndex: resultIndex
                )
            )
            nestedResults.append(nestedResult)
            return nestedResult
        }
        return nil
    }

    /// Subscript method to access the main transaction argument or the nested results
    /// based on the provided index.
    ///
    /// - Parameter index: The index representing the position of the nested result.
    /// - Returns: The main `transactionArgument` if `index` is 0, otherwise
    ///            retrieves or creates and returns the nested result corresponding to the index.
    public subscript(index: UInt16) -> TransactionArgument? {
        guard index > 0 else { return self.transactionArgument }
        return nestedResultFor(index)
    }
}
