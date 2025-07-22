//
//  File.swift
//  
//
//  Created by Marcus Arnett on 11/17/23.
//

import Foundation

public struct AttachRules {
    public static func attachKioskLockRuleTx(
        tx: inout TransactionBlock,
        type: String,
        policy: ObjectArgument,
        policyCap: ObjectArgument,
        packageId: String
    ) throws -> [TransactionArgument] {
        return try tx.moveCall(
            target: "\(packageId)::kiosk_lock_rule::add",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: policyCap).toTransactionArgument()
            ],
            typeArguments: [type]
        )
    }

    public static func attachRoyaltyRuleTx(
        tx: inout TransactionBlock,
        type: String,
        policy: ObjectArgument,
        policyCap: ObjectArgument,
        percentageBps: String,
        minAmount: String,
        packageId: String
    ) throws -> [TransactionArgument] {
        guard let percent = UInt16(percentageBps), let min = UInt64(minAmount) else { throw SuiError.notImplemented }
        guard percent >= 0 && percent <= 10_000 else { throw SuiError.notImplemented }

        return try tx.moveCall(
            target: "\(packageId)::royalty_rule::add",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: policyCap).toTransactionArgument(),
                .input(tx.pure(value: .uint16Number(percent))),
                .input(tx.pure(value: .number(min)))
            ],
            typeArguments: [type]
        )
    }

    public static func attachPersonalKioskRuleTx(
        tx: inout TransactionBlock,
        type: String,
        policy: ObjectArgument,
        policyCap: ObjectArgument,
        packageId: String
    ) throws -> [TransactionArgument] {
        return try tx.moveCall(
            target: "\(packageId)::personal_kiosk_rule::add",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: policyCap).toTransactionArgument()
            ],
            typeArguments: [type]
        )
    }

    public static func attachFloorPriceRuleTx(
        tx: inout TransactionBlock,
        type: String,
        policy: ObjectArgument,
        policyCap: ObjectArgument,
        minAmount: String,
        packageId: String
    ) throws -> [TransactionArgument] {
        guard let min = UInt64(minAmount) else { throw SuiError.notImplemented }
        return try tx.moveCall(
            target: "\(packageId)::floor_price_rule::add",
            arguments: [
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: policyCap).toTransactionArgument(),
                .input(tx.pure(value: .number(min)))
            ],
            typeArguments: [type]
        )
    }
}
