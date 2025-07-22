//
//  ResolveRules.swift
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

public struct ResolveRules {
    public static func resolveRoyaltyRule(param: RuleResolvingParams, transactionBlock tx: inout TransactionBlock) throws -> ObjectArgument {
        let policyObj = try tx.object(objectArgument: param.policyId)
        guard let price = UInt64(param.price) else { throw SuiError.notImplemented }
        let resultCalculateAmount = try tx.moveCall(
            target: "\(param.packageId)::royalty_rule::fee_amount",
            arguments: [
                policyObj.toTransactionArgument(),
                .input(try tx.pure(value: .number(price)))
            ],
            typeArguments: [param.itemType],
            returnValueCount: 2
        )
        guard
            let amount = resultCalculateAmount.first
        else { throw SuiError.notImplemented }
        let feeCoin = try tx.splitCoin(coin: tx.gas, amounts: [amount])
        let transferRequest = param.transferRequest.toTransactionArgument()
        let returnValue = try tx.moveCall(
            target: "\(param.packageId)::royalty_rule::pay",
            arguments: [
                policyObj.toTransactionArgument(),
                transferRequest,
                feeCoin
            ],
            typeArguments: [param.itemType]
        )
        guard let objArg = TransactionObjectArgument(from: returnValue[0]) else { throw SuiError.notImplemented }
        return .objectArgument(objArg)
    }

    public static func resolveKisokLockRule(param: RuleResolvingParams, transactionBlock tx: inout TransactionBlock) throws -> ObjectArgument {
        try KioskTransactions.lock(
            tx: &tx,
            itemType: param.itemType,
            kiosk: param.kiosk,
            kioskCap: param.kioskCap,
            policy: param.policyId,
            item: .objectArgument(param.purchasedItem)
        )
        let transferRequest = param.transferRequest.toTransactionArgument()
        let returnValue = try tx.moveCall(
            target: "\(param.packageId)::kiosk_lock_rule::prove",
            arguments: [
                transferRequest,
                try tx.object(objectArgument: param.kiosk).toTransactionArgument()
            ],
            typeArguments: [param.itemType]
        )
        guard let objArg = TransactionObjectArgument(from: returnValue[0]) else { throw SuiError.notImplemented }
        return .objectArgument(objArg)
    }

    public static func resolvePersonalKioskRule(param: RuleResolvingParams, transactionBlock tx: inout TransactionBlock) throws -> ObjectArgument {
        let transferRequest = param.transferRequest.toTransactionArgument()
        let returnValue = try tx.moveCall(
            target: "\(param.packageId)::personal_kiosk_rule::prove",
            arguments: [
                try tx.object(objectArgument: param.kiosk).toTransactionArgument(),
                transferRequest
            ],
            typeArguments: [param.itemType]
        )
        guard let objArg = TransactionObjectArgument(from: returnValue[0]) else { throw SuiError.notImplemented }
        return .objectArgument(objArg)
    }

    public static func resolveFloorPriceRule(param: RuleResolvingParams, transactionBlock tx: inout TransactionBlock) throws -> ObjectArgument {
        let transferRequest = param.transferRequest.toTransactionArgument()
        let returnValue = try tx.moveCall(
            target: "\(param.packageId)::floor_price_rule::prove",
            arguments: [
                try tx.object(objectArgument: param.policyId).toTransactionArgument(),
                transferRequest
            ],
            typeArguments: [param.itemType]
        )
        guard let objArg = TransactionObjectArgument(from: returnValue[0]) else { throw SuiError.notImplemented }
        return .objectArgument(objArg)
    }
}
