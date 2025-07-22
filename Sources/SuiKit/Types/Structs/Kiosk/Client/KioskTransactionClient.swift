//
//  KioskTransactionClient.swift
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
@preconcurrency import AnyCodable

/**
 * A helper for building transactions that involve kiosk.
 */
@available(iOS 16.0, *)
public class KioskTransactionClient {
    public var transactionBlock: TransactionBlock
    public let kioskClient: KioskClient
    public var kiosk: TransactionObjectArgument?
    public var kioskCap: TransactionObjectArgument?

    /// If we're pending `share` of a new kiosk, `finalize()` will share it.
    private var pendingShare: Bool?

    /// If we're pending transferring of the cap, `finalize()` will either error or transfer the cap if it's a new personal.
    private var pendingTransfer: Bool?

    /// The promise that the personalCap will be returned on `finalize()`.
    private var promise: TransactionArgument?

    /// The personal kiosk argument.
    private var personalCap: TransactionObjectArgument?

    /// A flag that checks whether kiosk TX is finalized.
    private var finalized: Bool = false

    public init(
        transactionBlock: inout TransactionBlock,
        kioskClient: KioskClient,
        kioskCap: KioskOwnerCap? = nil
    ) throws {
        self.transactionBlock = transactionBlock
        self.kioskClient = kioskClient
        self.kiosk = nil
        self.kioskCap = nil
        if let kioskCap { _ = try self.setCap(cap: kioskCap) }
    }

    /// Creates a kiosk and saves `kiosk` and `kioskOwnerCap` in state.
    /// Helpful if we want to chain some actions before sharing + transferring the cap to the specified address.
    public func create() throws -> KioskTransactionClient {
        try self.validateFinalizedStatus()
        self.setPendingStatuses(share: true, transfer: true)
        let result = try KioskTransactions.createKiosk(tx: &self.transactionBlock)
        self.kiosk = result.0
        self.kioskCap = result.1
        return self
    }

    /// Creates a personal kiosk & shares it.
    /// The `PersonalKioskCap` is transferred to the signer.
    /// - Parameter borrow: If true, the `kioskOwnerCap` is borrowed from the `PersonalKioskCap` to be used in next transactions.
    public func createPersonal(borrow: Bool? = nil) throws -> KioskTransactionClient {
        self.pendingShare = true
        return try self.create().convertToPersonal(borrow: borrow)
    }

    /**
     * Converts a kiosk to a Personal (Soulbound) Kiosk.
     * Requires initialization by either calling `ktxb.create()` or `ktxb.setCap()`.
    */
    public func convertToPersonal(borrow: Bool? = nil) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()
        let cap = try PersonalKioskTransactions.convertToPersonalTx(
            tx: &self.transactionBlock,
            kiosk: .objectArgument(self.kiosk!),
            kioskOwnerCap: .objectArgument(self.kioskCap!),
            packageId: self.kioskClient.getRulePackageId(rule: .personalKioskRulePackageId)
        )

        // if we enable `borrow`, we borrow the kioskCap from the cap.
        if borrow != nil, borrow! {
            _ = try self.borrowFromPersonalCap(
                personalCap: .objectArgument(
                    TransactionObjectArgument(from: cap)!
                )
            )
        } else { self.personalCap = TransactionObjectArgument(from: cap)! }

        self.setPendingStatuses(transfer: true)
        return self
    }

    /// Single function way to create a kiosk, share it and transfer the cap to the specified address.
    public func createAndShare(address: String) throws {
        try self.validateFinalizedStatus()
        let cap = try KioskTransactions.createKioskAndShare(tx: &self.transactionBlock)
        _ = try self.transactionBlock.transferObject(
            objects: [cap.toTransactionArgument()],
            address: address
        )
    }

    /// Shares the kiosk.
    public func share() throws {
        try self.validateKioskIsSet()
        self.setPendingStatuses(share: false)
        _ = try KioskTransactions.shareKiosk(
            tx: &self.transactionBlock,
            kiosk: self.kiosk!.toTransactionArgument()
        )
    }

    /**
     * Should be called only after `create` is called.
     * It shares the kiosk & transfers the cap to the specified address.
    */
    public func shareAndTransferCap(address: String) throws {
        guard self.personalCap == nil else { throw SuiError.notImplemented }
        self.setPendingStatuses(transfer: false)
        try self.share()
        _ = try self.transactionBlock.transferObject(
            objects: [self.kioskCap!.toTransactionArgument()],
            address: address
        )
    }

    /**
     * A function to borrow an item from a kiosk & execute any function with it.
     * Example: You could borrow a Fren out of a kiosk, attach an accessory (or mix), and return it.
    */
    public func borrowTx(
        itemType: String,
        itemId: String,
        closure: @escaping (TransactionArgument) throws -> Void
    ) throws {
        try self.validateKioskIsSet()
        let result = try KioskTransactions.borrowValue(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            itemId: itemId
        )
        try closure(result.0)
        try self.returnValue(
            itemType: itemType,
            item: result.0,
            promise: result.1
        )
    }

    /**
     * Borrows an item from the kiosk.
     * This will fail if the item is listed for sale.
     *
     * Requires calling `returnValue`.
    */
    public func borrow(
        itemType: String,
        itemId: String
    ) throws -> (TransactionArgument, TransactionArgument) {
        try self.validateKioskIsSet()
        let result = try KioskTransactions.borrowValue(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            itemId: itemId
        )
        return (result.0, result.1)
    }

    /**
     * Returns the item back to the kiosk.
     * Accepts the parameters returned from the `borrow` function.
    */
    public func returnValue(
        itemType: String,
        item: TransactionArgument,
        promise: TransactionArgument
    ) throws {
        try self.validateKioskIsSet()
        try KioskTransactions.returnValue(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            item: item,
            promise: promise
        )
    }

    /// A function to withdraw from kiosk
    /// - Parameters:
    ///   - address: Where to trasnfer the coin.
    ///   - amount: The amount we aim to withdraw.
    public func withdraw(address: String, amount: String? = nil) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        let coin = try KioskTransactions.withdrawFromKiosk(
            tx: &self.transactionBlock,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            amount: amount
        )

        _ = try self.transactionBlock.transferObject(
            objects: [coin.toTransactionArgument()],
            address: address
        )

        return self
    }

    /// A function to place an item in the kiosk.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - item: The ID or Transaction Argument of the item
    public func place(itemType: String, item: ObjectArgument) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        try KioskTransactions.place(
            tx: &self.transactionBlock,
            itemType: itemType, kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            item: item
        )

        return self
    }

    /// A function to place an item in the kiosk and list it for sale in one transaction.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - item: The ID or Transaction Argument of the item
    ///   - price: The price in MIST
    public func placeAndList(itemType: String, item: ObjectArgument, price: String) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        try KioskTransactions.placeAndList(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            item: item,
            price: price
        )

        return self
    }

    /// A function to list an item in the kiosk.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - itemId: The ID of the item
    ///   - price: The price in MIST
    public func list(itemType: String, itemId: String, price: String) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        try KioskTransactions.list(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            itemId: itemId,
            price: price
        )

        return self
    }

    /// A function to delist an item from the kiosk.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - itemId: The ID of the item
    public func delist(itemType: String, itemId: String) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        try KioskTransactions.delist(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            itemId: itemId
        )

        return self
    }

    /// A function to take an item from the kiosk. The transaction won't succeed if the item is listed or locked.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - itemId: The ID of the item
    public func take(itemType: String, itemId: String) throws -> TransactionObjectArgument {
        try self.validateKioskIsSet()

        return try KioskTransactions.take(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            itemId: itemId
        )
    }

    /// Transfer a non-locked/non-listed item to an address.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - itemId: The ID of the item
    ///   - address: The destination address
    public func transfer(itemType: String, itemId: String, address: String) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        let item = try self.take(itemType: itemType, itemId: itemId)
        _ = try self.transactionBlock.transferObject(
            objects: [item.toTransactionArgument()],
            address: address
        )

        return self
    }

    /// A function to take lock an item in the kiosk.
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - itemId: The ID of the item
    ///   - policy: The Policy ID or Transaction Argument for item T
    public func lock(
        itemType: String,
        itemId: ObjectArgument,
        policy: ObjectArgument
    ) throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        try KioskTransactions.lock(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: .objectArgument(self.kiosk!),
            kioskCap: .objectArgument(self.kioskCap!),
            policy: policy,
            item: itemId
        )

        return self
    }

    /// Purchase an item from a seller's kiosk.
    /// Can be called like: `let (item, transferRequest) = try kioskTx.purchase(...)`
    /// - Parameters:
    ///   - itemType: The type `T` of the item
    ///   - itemId: The ID of the item
    ///   - price: The price in MIST
    ///   - sellerkiosk: The kiosk which is selling the item. Can be an id or an object argument.
    public func purchase(
        itemType: String,
        itemId: String,
        price: UInt64,
        sellerkiosk: ObjectArgument
    ) throws -> (TransactionObjectArgument, TransactionObjectArgument) {
        // Split the coin for the amount of the listing.
        let result = try self.transactionBlock.splitCoin(
            coin: self.transactionBlock.gas,
            amounts: [
                try self.transactionBlock.pure(value: .number(price))
            ]
        )

        return try KioskTransactions.purchase(
            tx: &self.transactionBlock,
            itemType: itemType,
            kiosk: sellerkiosk,
            itemId: itemId,
            payment: .objectArgument(
                TransactionObjectArgument(from: result)!
            )
        )
    }

    /// A function to purchase and resolve a transfer policy.
    /// If the transfer policy has the `lock` rule, the item is locked in the kiosk.
    /// Otherwise, the item is placed in the kiosk.
    /// - Parameters:
    ///   - itemType: The type of the item
    ///   - itemId: The id of the item
    ///   - price: The price of the specified item
    ///   - sellerKiosk: The kiosk which is selling the item. Can be an id or an object argument.
    ///   - extraArgs: Used to pass arguments for custom rule resolvers.
    public func purchaseAndResolve(
        itemType: String,
        itemId: String,
        price: UInt64,
        sellerKiosk: ObjectArgument,
        extraArgs: PurchaseOptions = PurchaseOptions()
    ) async throws -> KioskTransactionClient {
        try self.validateKioskIsSet()

        // Get a list of the transfer policies.
        let policies = try await self.kioskClient.getTransferPolicies(type: itemType)

        // TODO: Implement parameter for choosing policy
        guard let policy = policies.first else {
            throw SuiError.notImplemented
        }

        // Initialize the purchase `kiosk::purchase`
        let (purchasedItem, transferRequest) = try self.purchase(
            itemType: itemType,
            itemId: itemId,
            price: price,
            sellerkiosk: sellerKiosk
        )
        var canTransferOutsideKiosk = true

        for rule in policy.rules {
            let ruleDefinitionRaw = try self.kioskClient.rules.filter { policyRule in
                let lhs = try KioskUtilities.getNormalizedRuleType(rule: policyRule.rule)
                let rhs = try KioskUtilities.getNormalizedRuleType(rule: rule)
                return lhs == rhs
            }

            guard let ruleDefinition = ruleDefinitionRaw.first else { throw SuiError.notImplemented }
            if ruleDefinition.hasLockingRule != nil, ruleDefinition.hasLockingRule! {
                canTransferOutsideKiosk = false
            }

            _ = try ruleDefinition.resolveRuleFunction!(
                RuleResolvingParams(
                    itemType: itemType,
                    itemId: itemId,
                    price: "\(price)",
                    policyId: .string(policy.id.hex()),
                    sellerKiosk: sellerKiosk,
                    kiosk: .objectArgument(self.kiosk!),
                    kioskCap: .objectArgument(self.kioskCap!),
                    transferRequest: transferRequest,
                    purchasedItem: purchasedItem,
                    packageId: ruleDefinition.packageId,
                    extraArgs: extraArgs.extraArgs ?? [:]
                ),
                &self.transactionBlock
            )
        }

        try TransferPolicyTransactions.confirmRequest(
            tx: &self.transactionBlock,
            itemType: itemType,
            policy: .string(policy.id.hex()),
            request: transferRequest.toTransactionArgument()
        )

        if canTransferOutsideKiosk {
            return try self.place(
                itemType: itemType,
                item: .objectArgument(purchasedItem)
            )
        }

        return self
    }

    /// A function to setup the client using an existing `ownerCap`,
    /// as return from the `kioskClient.getOwnedKiosks` function.
    /// - Parameter cap: KioskOwnerCap` object as returned from `getOwnedKiosks` SDK call.
    public func setCap(cap: KioskOwnerCap) throws -> KioskTransactionClient {
        try self.validateFinalizedStatus()

        self.kiosk = try self.transactionBlock.object(value: .string(cap.kioskId))
        if let isPersonal = cap.isPersonal, !isPersonal {
            self.kioskCap = try self.transactionBlock.object(value: .string(cap.objectId))
            return self
        }

        return try self.borrowFromPersonalCap(personalCap: .string(cap.objectId))
    }

    /**
     *    A function that ends up the kiosk building txb & returns the `kioskOwnerCap` back to the
     *  `PersonalKioskCap`, in case we are operating on a personal kiosk.
     *     It will also share the `kiosk` if it's not shared, and finalize the transfer of the personal cap if it's pending.
    */
    public func finalize() throws {
        try self.validateKioskIsSet()

        // If we're pending the sharing of the new kiosk, share it.
        if self.pendingShare != nil, self.pendingShare! { try self.share() }

        // If we're operating on a non-personal kiosk, we don't need to do anything else.
        if self.personalCap == nil {
            // If we're pending transfer though, we inform user to call `shareAndTransferCap()`.
            if self.pendingTransfer != nil && self.pendingTransfer! {
                throw SuiError.customError(message: "You need to transfer the `kioskOwnerCap` by calling `shareAndTransferCap()` before wrap")
            }
            return
        }

        let packageId = try self.kioskClient.getRulePackageId(rule: .personalKioskRulePackageId)

        // if we have a promise, return the `ownerCap` back to the personal cap.
        if let promise = self.promise {
            _ = try self.transactionBlock.moveCall(
                target: "\(packageId)::personal_kiosk::return_val",
                arguments: [
                    self.personalCap!.toTransactionArgument(),
                    try self.transactionBlock.object(
                        objectArgument: .objectArgument(self.kioskCap!)
                    ).toTransactionArgument(),
                    promise
                ]
            )
        }

        // If we are pending transferring the personalCap, we do it here.
        if self.pendingTransfer != nil, self.pendingTransfer! {
            try PersonalKioskTransactions.transferPersonalCapTx(
                tx: &self.transactionBlock,
                personalKioskCap: self.personalCap!,
                packageId: packageId
            )
        }

        // Mark the transaction block as finalized, so no other functions can be called.
        self.finalized = true
    }

    // MARK: Setters
    public func setKioskCap(cap: TransactionObjectArgument) throws -> KioskTransactionClient {
        try self.validateFinalizedStatus()
        self.kioskCap = cap
        return self
    }

    public func setKiosk(kiosk: TransactionObjectArgument) throws -> KioskTransactionClient {
        try self.validateFinalizedStatus()
        self.kiosk = kiosk
        return self
    }

    // MARK: Getters
    /// Returns the active transaction's kiosk, or undefined if `setCap` or `create()` hasn't been called yet.
    public func getKiosk() throws -> TransactionObjectArgument {
        try self.validateFinalizedStatus()
        guard self.kiosk != nil else { throw SuiError.notImplemented }
        return self.kiosk!
    }

    /// Returns the active transaction's kioskOwnerCap, or undefined if `setCap` or `create()` hasn't been called yet.
    public func getKioskCap() throws -> TransactionObjectArgument {
        try self.validateFinalizedStatus()
        guard self.kioskCap != nil else { throw SuiError.notImplemented }
        return self.kioskCap!
    }

    /**
     * A function to borrow from `personalCap`.
    */
    private func borrowFromPersonalCap(personalCap: ObjectArgument) throws -> KioskTransactionClient {
        let rulePackageId = try self.kioskClient.getRulePackageId(rule: .personalKioskRulePackageId)
        let result = try self.transactionBlock.moveCall(
            target: "\(rulePackageId)::personal_kiosk::borrow_val",
            arguments: [try self.transactionBlock.object(objectArgument: personalCap).toTransactionArgument()],
            returnValueCount: 2
        )
        self.kioskCap = TransactionObjectArgument(from: result[0])
        self.personalCap = try self.transactionBlock.object(objectArgument: personalCap)
        self.promise = result[1]
        return self
    }

    private func setPendingStatuses(share: Bool? = nil, transfer: Bool? = nil) {
        if let transfer { self.pendingTransfer = transfer }
        if let share { self.pendingShare = share }
    }

    private func validateKioskIsSet() throws {
        try self.validateFinalizedStatus()
        guard self.kiosk != nil, self.kioskCap != nil else { throw SuiError.notImplemented }
    }

    private func validateFinalizedStatus() throws {
        guard !(self.finalized) else { throw SuiError.notImplemented }
    }
}
