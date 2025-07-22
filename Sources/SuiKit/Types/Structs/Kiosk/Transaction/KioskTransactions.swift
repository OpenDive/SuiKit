//
//  KioskTransactions.swift
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

public struct KioskTransactions {
    /// Create a new shared Kiosk and returns the [kiosk, kioskOwnerCap] tuple.
    public static func createKiosk(
        tx: inout TransactionBlock
    ) throws -> (TransactionObjectArgument, TransactionObjectArgument) {
        let result = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::new",
            returnValueCount: 2
        )

        guard
            let kiosk = TransactionObjectArgument(from: result[0]),
            let kioskOwnerCap = TransactionObjectArgument(from: result[1])
        else { throw SuiError.customError(message: "Invalid object argument") }

        return (kiosk, kioskOwnerCap)
    }

    /// Calls the `kiosk::new()` function and shares the kiosk.
    /// - Returns: A `kioskOwnerCap` object.
    public static func createKioskAndShare(
        tx: inout TransactionBlock
    ) throws -> TransactionObjectArgument {
        let (kioskObj, kioskOwnerCap) = try Self.createKiosk(
            tx: &tx
        )
        _ = try Self.shareKiosk(
            tx: &tx,
            kiosk: kioskObj.toTransactionArgument()
        )
        return kioskOwnerCap
    }

    /// Converts Transfer Policy to a shared object.
    public static func shareKiosk(
        tx: inout TransactionBlock,
        kiosk: TransactionArgument
    ) throws {
        _ = try tx.moveCall(
            target: "0x2::transfer::public_share_object",
            arguments: [kiosk],
            typeArguments: [KioskConstants.kioskType]
        )
    }

    /// Call the `kiosk::place<T>(Kiosk, KioskOwnerCap, Item)` function.
    /// Place an item to the Kiosk.
    public static func place(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        item: ObjectArgument
    ) throws {
        _ = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::place",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                tx.object(objectArgument: item).toTransactionArgument()
            ],
            typeArguments: [itemType]
        )
    }

    /**
     * Call the `kiosk::lock<T>(Kiosk, KioskOwnerCap, TransferPolicy, Item)`
     * function. Lock an item in the Kiosk.
     *
     * Unlike `place` this function requires a `TransferPolicy` to exist
     * and be passed in. This is done to make sure the item does not get
     * locked without an option to take it out.
     */
    public static func lock(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        policy: ObjectArgument,
        item: ObjectArgument
    ) throws {
        _ = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::lock",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                tx.object(objectArgument: policy).toTransactionArgument(),
                tx.object(objectArgument: item).toTransactionArgument()
            ],
            typeArguments: [itemType]
        )
    }

    /**
     * Call the `kiosk::take<T>(Kiosk, KioskOwnerCap, ID)` function.
     * Take an item from the Kiosk.
     */
    public static func take(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        itemId: String
    ) throws -> TransactionObjectArgument {
        let result = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::take",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                .input(tx.pure(value: .address(try AccountAddress.fromHex(itemId))))
            ],
            typeArguments: [itemType]
        )
        guard let returnValue = TransactionObjectArgument(from: result[0]) else {
            throw SuiError.customError(message: "Invalid object argument")
        }
        return returnValue
    }

    /**
     * Call the `kiosk::list<T>(Kiosk, KioskOwnerCap, ID, u64)` function.
     * List an item for sale.
     */
    public static func list(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        itemId: String,
        price: String
    ) throws {
        guard let priceU64 = UInt64(price) else { throw SuiError.customError(
            message: "Invalid number: \(price)"
        ) }

        _ = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::list",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                .input(tx.pure(value: .address(try AccountAddress.fromHex(itemId)))),
                .input(tx.pure(value: .number(priceU64)))
            ],
            typeArguments: [itemType]
        )
    }

    /**
     * Call the `kiosk::list<T>(Kiosk, KioskOwnerCap, ID, u64)` function.
     * List an item for sale.
     */
    public static func delist(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        itemId: String
    ) throws {
        _ = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::delist",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                .input(tx.pure(value: .address(try AccountAddress.fromHex(itemId))))
            ],
            typeArguments: [itemType]
        )
    }

    /**
     * Call the `kiosk::place_and_list<T>(Kiosk, KioskOwnerCap, Item, u64)` function.
     * Place an item to the Kiosk and list it for sale.
     */
    public static func placeAndList(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        item: ObjectArgument,
        price: String
    ) throws {
        guard let priceU64 = UInt64(price) else { throw SuiError.customError(
            message: "Invalid number: \(price)"
        ) }

        _ = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::place_and_list",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                tx.object(objectArgument: item).toTransactionArgument(),
                .input(tx.pure(value: .number(priceU64)))
            ],
            typeArguments: [itemType]
        )
    }

    /**
     * Call the `kiosk::purchase<T>(Kiosk, ID, Coin<SUI>)` function and receive an Item and
     * a TransferRequest which needs to be dealt with (via a matching TransferPolicy).
     */
    public static func purchase(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        itemId: String,
        payment: ObjectArgument
    ) throws -> (TransactionObjectArgument, TransactionObjectArgument) {
        let result = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::purchase",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                .input(tx.pure(value: .address(try AccountAddress.fromHex(itemId)))),
                tx.object(objectArgument: payment).toTransactionArgument()
            ],
            typeArguments: [itemType],
            returnValueCount: 2
        )

        guard
            let item = TransactionObjectArgument(from: result[0]),
            let transferRequest = TransactionObjectArgument(from: result[1])
        else { throw SuiError.customError(message: "Invalid object argument") }

        return (item, transferRequest)
    }

    /**
     * Call the `kiosk::withdraw(Kiosk, KioskOwnerCap, Option<u64>)` function and receive a Coin<SUI>.
     * If the amount is null, then the entire balance will be withdrawn.
     */
    public static func withdrawFromKiosk(
        tx: inout TransactionBlock,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        amount: String?
    ) throws -> TransactionObjectArgument {
        var amountArg: UInt64?

        if
            let amount,
            let outputU64 = UInt64(amount) {
            amountArg = outputU64
        }

        let ser = Serializer()
        try ser._optional(amountArg, Serializer.u64)

        let result = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::withdraw",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                .input(try tx.pure(data: ser.output()))
            ]
        )

        guard
            let coinObj = result.first,
            let coin = TransactionObjectArgument(from: coinObj)
        else { throw SuiError.customError(message: "Invalid object argument") }

        return coin
    }

    /**
     * Call the `kiosk::borrow_value<T>(Kiosk, KioskOwnerCap, ID): T` function.
     * Immutably borrow an item from the Kiosk and return it in the end.
     *
     * Requires calling `returnValue` to return the item.
     */
    public static func borrowValue(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        kioskCap: ObjectArgument,
        itemId: String
    ) throws -> (TransactionArgument, TransactionArgument) {
        let result = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::borrow_val",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                tx.object(objectArgument: kioskCap).toTransactionArgument(),
                .input(tx.pure(value: .address(try AccountAddress.fromHex(itemId))))
            ],
            typeArguments: [itemType],
            returnValueCount: 2
        )

        guard
            let item = result.first,
            result.count == 2
        else { throw SuiError.customError(message: "Invalid object argument") }

        return (item, result[1])
    }

    /**
     * Call the `kiosk::return_value<T>(Kiosk, Item, Borrow)` function.
     * Return an item to the Kiosk after it was `borrowValue`-d.
     */
    public static func returnValue(
        tx: inout TransactionBlock,
        itemType: String,
        kiosk: ObjectArgument,
        item: TransactionArgument,
        promise: TransactionArgument
    ) throws {
        _ = try tx.moveCall(
            target: "\(KioskConstants.kioskModule)::return_val",
            arguments: [
                tx.object(objectArgument: kiosk).toTransactionArgument(),
                item,
                promise
            ],
            typeArguments: [itemType]
        )
    }
}
