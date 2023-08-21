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

public class TransactionResult {
    let transactionArgument: TransactionArgument
    var nestedResults: [TransactionArgument]

    public init(index: UInt16) {
        self.transactionArgument = TransactionArgument.result(
            Result(index: index)
        )
        self.nestedResults = []
    }

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

    public subscript(index: UInt16) -> TransactionArgument? {
        guard index > 0 else { return self.transactionArgument }
        return nestedResultFor(index)
    }
}
