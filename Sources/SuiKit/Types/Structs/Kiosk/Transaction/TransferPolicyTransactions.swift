//
//  TransferPolicyTransactions.swift
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

public struct TransferPolicyTransactions {
    /**
     * Call the `transfer_policy::new` function to create a new transfer policy.
     * Returns `tra/Volumes/OpenDive/Github/SuiKit-Devel/SuiKit/Sources/SuiKitnsferPolicyCap`
     */
    public static func createTransferPolicy(
        tx: inout TransactionBlock,
        itemType: String,
        publisher: ObjectArgument
    ) throws -> TransactionArgument {
        let (transferPolicy, transferPolicyCap) = try Self.createTransferPolicyWithoutSharing(
            tx: &tx,
            itemType: itemType,
            publisher: publisher
        )

        guard let txPolicyObj = TransactionObjectArgument(
            from: transferPolicy
        ) else { throw SuiError.customError(message: "Invalid object argument") }

        try Self.shareTransferPolicy(tx: &tx, itemType: itemType, transferPolicy: txPolicyObj)

        return transferPolicyCap
    }

    /**
     * Creates a transfer Policy and returns both the Policy and the Cap.
     * Used if we want to use the policy before making it a shared object.
     */
    public static func createTransferPolicyWithoutSharing(
        tx: inout TransactionBlock,
        itemType: String,
        publisher: ObjectArgument
    ) throws -> (TransactionArgument, TransactionArgument) {
        let result = try tx.moveCall(
            target: "\(TransferPolicyConstants.transferPolicyModule)::new",
            arguments: [
                try tx.object(
                    objectArgument: publisher
                ).toTransactionArgument()
            ],
            typeArguments: [itemType],
            returnValueCount: 2
        )

        guard
            let transferPolicy = result.first,
            result.count == 2
        else { throw SuiError.customError(message: "Invalid object argument") }

        return (transferPolicy, result[1])
    }

    /**
     * Converts Transfer Policy to a shared object.
     */
    public static func shareTransferPolicy(
        tx: inout TransactionBlock,
        itemType: String,
        transferPolicy: TransactionObjectArgument
    ) throws {
        _ = try tx.moveCall(
            target: "0x2::transfer::public_share_object",
            arguments: [transferPolicy.toTransactionArgument()],
            typeArguments: [
                "\(TransferPolicyConstants.transferPolicyType)<\(itemType)>"
            ]
        )
    }

    /**
     * Call the `transfer_policy::withdraw` function to withdraw profits from a transfer policy.
     */
    public static func withdrawFromPolicy(
        tx: inout TransactionBlock,
        itemType: String,
        policy: ObjectArgument,
        policyCap: ObjectArgument,
        amount: String? = nil
    ) throws -> TransactionArgument {
        var amountArg: UInt64?

        if
            let amount,
            let outputU64 = UInt64(amount) {
            amountArg = outputU64
        }

        let ser = Serializer()
        try ser._optional(amountArg, Serializer.u64)

        let result = try tx.moveCall(
            target: "\(TransferPolicyConstants.transferPolicyModule)::withdraw",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: policyCap).toTransactionArgument(),
                .input(try tx.pure(data: ser.output()))
            ],
            typeArguments: [itemType],
            returnValueCount: 2
        )

        guard let profits = result.first else {
            throw SuiError.customError(message: "Invalid object argument")
        }

        return profits
    }

    /**
     * Call the `transfer_policy::confirm_request` function to unblock the
     * transaction.
     */
    public static func confirmRequest(
        tx: inout TransactionBlock,
        itemType: String,
        policy: ObjectArgument,
        request: TransactionArgument
    ) throws {
        _ = try tx.moveCall(
            target: "\(TransferPolicyConstants.transferPolicyModule)::confirm_request",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                request
            ],
            typeArguments: [itemType]
        )
    }

    /**
     * Calls the `transfer_policy::remove_rule` function to remove a Rule from the transfer policy's ruleset.
     */
    public static func removeTransferPolicyRule(
        tx: inout TransactionBlock,
        itemType: String,
        ruleType: String,
        configType: String,
        policy: ObjectArgument,
        policyCap: ObjectArgument
    ) throws {
        _ = try tx.moveCall(
            target: "\(TransferPolicyConstants.transferPolicyModule)::remove_rule",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: policyCap).toTransactionArgument()
            ],
            typeArguments: [
                itemType,
                ruleType,
                configType
            ]
        )
    }
}
