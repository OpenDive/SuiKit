//
//  TransferPolicyTransactionClient.swift
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

@available(iOS 16.0, *)
public class TransferPolicyTransactionClient {
    public var transactionBlock: TransactionBlock
    public var kioskClient: KioskClient
    public var policy: ObjectArgument?
    public var policyCap: ObjectArgument?
    public var type: String?

    public init(
        params: TransferPolicyTransactionParams,
        transactionBlock: inout TransactionBlock
    ) {
        self.transactionBlock = transactionBlock
        self.kioskClient = params.kioskClient
        self.policy = nil
        self.policyCap = nil
        self.type = nil
        if let policyCap = params.cap {
            _ = self.setCap(cap: policyCap)
        }
    }

    /// A function to create a new transfer policy.
    /// Checks if there's already an existing transfer policy to prevent
    /// double transfer polciy mistakes.
    /// There's an optional `skipCheck` flag that will just create the policy
    /// without checking
    /// - Parameters:
    ///   - params: The parameters used for the transfer policy.
    ///   - address: Address to save the `TransferPolicyCap` object to.
    public func createAndShare(
        params: TransferPolicyBaseParams,
        address: String
    ) async throws {
        try await self.checkPolicies(params: params)

        let cap = try TransferPolicyTransactions.createTransferPolicy(
            tx: &self.transactionBlock,
            itemType: params.type,
            publisher: params.publisher
        )
        _ = try self.transactionBlock.transferObject(
            objects: [cap],
            address: address
        )
    }

    /// A convenient function to create a Transfer Policy and attach some rules
    /// before sharing it (so you can prepare it in a single PTB)
    /// - Parameter params: The parameters used for the transfer policy.
    public func create(
        params: TransferPolicyBaseParams
    ) async throws -> TransferPolicyTransactionClient {
        try await self.checkPolicies(params: params)

        let (policy, policyCap) = try TransferPolicyTransactions.createTransferPolicyWithoutSharing(
            tx: &self.transactionBlock,
            itemType: params.type,
            publisher: params.publisher
        )

        return self.setup(
            policyId: .objectArgument(TransactionObjectArgument(from: policy)!),
            policyCap: .objectArgument(TransactionObjectArgument(from: policyCap)!),
            type: params.type
        )
    }

    /// This can be called after calling the `create` function to share the `TransferPolicy`,
    /// and transfer the `TransferPolicyCap` to the specified address
    /// - Parameter address: The address to transfer the `TransferPolicyCap`
    public func shareAndTransferCap(address: String) async throws {
        guard
            let type = self.type,
            let policyCapObj = self.policyCap,
            let policyObj = self.policy,
            case .objectArgument(let policy) = policyObj,
            case .objectArgument(let policyCap) = policyCapObj
        else {
            throw SuiError.notImplemented
        }

        try TransferPolicyTransactions.shareTransferPolicy(
            tx: &self.transactionBlock,
            itemType: type,
            transferPolicy: policy
        )

        _ = try self.transactionBlock.transferObject(
            objects: [policyCap.toTransactionArgument()],
            address: address
        )
    }

    /// Setup the TransferPolicy by passing a `cap` returned from `kioskClient.getOwnedTransferPolicies` or
    /// `kioskClient.getOwnedTransferPoliciesByType`.
    /// - Parameter cap: The `TransferPolicyCap`
    public func setCap(cap: TransferPolicyCap) -> TransferPolicyTransactionClient {
        return self.setup(
            policyId: .string(cap.policyId),
            policyCap: .string(cap.policyCapId),
            type: cap.type
        )
    }

    /// Withdraw from the transfer policy's profits.
    /// - Parameters:
    ///   - address: Address to transfer the profits to.
    ///   - amount: Amount parameter. Will withdraw all profits if the amount is not specified.
    public func withdraw(address: String, amount: String? = nil) throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        // Withdraw coin for specified amount (or none)
        let coin = try TransferPolicyTransactions.withdrawFromPolicy(
            tx: &self.transactionBlock,
            itemType: self.type!,
            policy: self.policy!,
            policyCap: self.policyCap!,
            amount: amount
        )
        _ = try self.transactionBlock.transferObject(
            objects: [coin],
            address: address
        )

        return self
    }

    /// Adds the Kiosk Royalty rule to the Transfer Policy.
    /// You can pass the percentage, as well as a minimum amount.
    /// The royalty that will be paid is the MAX(percentage, minAmount).
    /// You can pass 0 in either value if you want only percentage royalty, or a fixed amount fee.
    /// (but you should define at least one of them for the rule to make sense).
    /// - Parameters:
    ///   - percentageBps: The royalty percentage in basis points. Use `percentageToBasisPoints` helper to convert from percentage [0,100].
    ///   - minAmount: The minimum royalty amount per request in MIST.
    public func addRoyaltyRule(
        percentageBps: String,  // this is in basis points.
        minAmount: String
    ) throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        // Hard-coding package Ids as these don't change.
        // Also, it's hard to keep versioning as with network wipes, mainnet
        // and testnet will conflict.
        _ = try AttachRules.attachRoyaltyRuleTx(
            tx: &self.transactionBlock,
            type: self.type!,
            policy: self.policy!,
            policyCap: self.policyCap!,
            percentageBps: percentageBps,
            minAmount: minAmount,
            packageId: try self.kioskClient.getRulePackageId(
                rule: .royaltyRulePackageId
            )
        )

        return self
    }

    /// Adds the Kiosk Lock Rule to the Transfer Policy.
    /// This Rule forces buyer to lock the item in the kiosk, preserving strong royalties.
    public func addLockRule() throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        _ = try AttachRules.attachKioskLockRuleTx(
            tx: &self.transactionBlock,
            type: self.type!,
            policy: self.policy!,
            policyCap: self.policyCap!,
            packageId: try self.kioskClient.getRulePackageId(
                rule: .kioskLockRulePackageId
            )
        )

        return self
    }

    /// Attaches the Personal Kiosk Rule, making a purchase valid only for `SoulBound` kiosks.
    public func addPersonalKioskRule() throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        _ = try AttachRules.attachPersonalKioskRuleTx(
            tx: &self.transactionBlock,
            type: self.type!,
            policy: self.policy!,
            policyCap: self.policyCap!,
            packageId: try self.kioskClient.getRulePackageId(
                rule: .personalKioskRulePackageId
            )
        )

        return self
    }

    /// A function to add the floor price rule to a transfer policy.
    /// - Parameter minPrice: The minimum price in MIST.
    public func addFloorPriceRule(minPrice: String) throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        _ = try AttachRules.attachFloorPriceRuleTx(
            tx: &self.transactionBlock,
            type: self.type!,
            policy: self.policy!,
            policyCap: self.policyCap!,
            minAmount: minPrice,
            packageId: try self.kioskClient.getRulePackageId(
                rule: .floorPriceRulePackageId
            )
        )

        return self
    }

    /// Generic helper to remove a rule, not from the SDK's base ruleset.
    /// - Parameters:
    ///   - ruleType: The Rule Type
    ///   - configType: The Config Type
    public func removeRule(ruleType: String, configType: String) throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        _ = try TransferPolicyTransactions.removeTransferPolicyRule(
            tx: &self.transactionBlock,
            itemType: self.type!,
            ruleType: ruleType,
            configType: configType,
            policy: self.policy!,
            policyCap: self.policyCap!
        )

        return self
    }

    /// Removes the lock rule.
    public func removeLockRule() throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        let packageId = try self.kioskClient.getRulePackageId(
            rule: .kioskLockRulePackageId
        )
        _ = try TransferPolicyTransactions.removeTransferPolicyRule(
            tx: &self.transactionBlock,
            itemType: self.type!,
            ruleType: "\(packageId)::kiosk_lock_rule::Rule",
            configType: "\(packageId)::kiosk_lock_rule::Config",
            policy: self.policy!,
            policyCap: self.policyCap!
        )

        return self
    }

    /// Removes the Royalty rule
    public func removeRoyaltyRule() throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        let packageId = try self.kioskClient.getRulePackageId(
            rule: .royaltyRulePackageId
        )
        _ = try TransferPolicyTransactions.removeTransferPolicyRule(
            tx: &self.transactionBlock,
            itemType: self.type!,
            ruleType: "\(packageId)::royalty_rule::Rule",
            configType: "\(packageId)::royalty_rule::Config",
            policy: self.policy!,
            policyCap: self.policyCap!
        )

        return self
    }

    public func removePersonalKioskRule() throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        let packageId = try self.kioskClient.getRulePackageId(rule: .personalKioskRulePackageId)
        _ = try TransferPolicyTransactions.removeTransferPolicyRule(
            tx: &self.transactionBlock,
            itemType: self.type!,
            ruleType: "\(packageId)::personal_kiosk_rule::Rule",
            configType: "bool",
            policy: self.policy!,
            policyCap: self.policyCap!
        )

        return self
    }

    public func removeFloorPriceRule() throws -> TransferPolicyTransactionClient {
        try self.validateInputs()

        let packageId = try self.kioskClient.getRulePackageId(
            rule: .floorPriceRulePackageId
        )
        _ = try TransferPolicyTransactions.removeTransferPolicyRule(
            tx: &self.transactionBlock,
            itemType: self.type!,
            ruleType: "\(packageId)::floor_price_rule::Rule",
            configType: "\(packageId)::floor_price_rule::Config",
            policy: self.policy!,
            policyCap: self.policyCap!
        )

        return self
    }

    public func getPolicy() throws -> ObjectArgument {
        guard let policy = self.policy else {
            throw SuiError.notImplemented
        }
        return policy
    }

    public func getPolicyCap() throws -> ObjectArgument {
        guard let policyCap = self.policyCap else {
            throw SuiError.notImplemented
        }
        return policyCap
    }

    /// Internal function that that the policy's Id + Cap + type have been set.
    private func validateInputs() throws {
        let genericErrorMessage = "Please use 'setCap()' to setup the TransferPolicy."
        if self.policy == nil {
            throw SuiError.customError(
                message: "\(genericErrorMessage) Missing: Transfer Policy Object."
            )
        }
        if self.policyCap == nil {
            throw SuiError.customError(
                message: "\(genericErrorMessage) Missing: TransferPolicyCap Object ID"
            )
        }
        if self.type == nil {
            throw SuiError.customError(
                message: "\(genericErrorMessage) Missing: Transfer Policy object type (e.g. {packageId}::item::Item)"
            )
        }
    }

    private func checkPolicies(params: TransferPolicyBaseParams) async throws {
        if params.skipCheck != nil, !(params.skipCheck!) {
            let policies = try await self.kioskClient.getTransferPolicies(
                type: params.type
            )
            guard !(policies.isEmpty) else {
                throw SuiError.customError(
                    message: "Invalid transfer policy"
                )
            }
        }
    }

    /**
     * Setup the state of the TransferPolicyTransaction.
    */
    private func setup(
        policyId: ObjectArgument,
        policyCap: ObjectArgument,
        type: String?
    ) -> TransferPolicyTransactionClient {
        self.policy = policyId
        self.policyCap = policyCap
        self.type = type

        return self
    }
}
