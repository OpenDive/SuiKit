//
//  RuleAddresses.swift
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

public struct RuleAddresses {
    nonisolated(unsafe) public static let royaltyRuleAddress: [KioskNetwork: String] = [
        KioskNetwork.testnet: "bd8fc1947cf119350184107a3087e2dc27efefa0dd82e25a1f699069fe81a585",
        KioskNetwork.mainnet: "0x434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879",
        KioskNetwork.custom: ""
    ]

    nonisolated(unsafe) public static let kioskLockRuleAddress: [KioskNetwork: String] = [
        KioskNetwork.testnet: "bd8fc1947cf119350184107a3087e2dc27efefa0dd82e25a1f699069fe81a585",
        KioskNetwork.mainnet: "0x434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879",
        KioskNetwork.custom: ""
    ]

    nonisolated(unsafe) public static let floorPriceRuleAddres: [KioskNetwork: String] = [
        KioskNetwork.testnet: "0x06f6bdd3f2e2e759d8a4b9c252f379f7a05e72dfe4c0b9311cdac27b8eb791b1",
        KioskNetwork.mainnet: "0x34cc6762780f4f6f153c924c0680cfe2a1fb4601e7d33cc28a92297b62de1e0e",
        KioskNetwork.custom: ""
    ]

    nonisolated(unsafe) public static let personalKioskRuleAddress: [KioskNetwork: String] = [
        KioskNetwork.testnet: "0x06f6bdd3f2e2e759d8a4b9c252f379f7a05e72dfe4c0b9311cdac27b8eb791b1",
        KioskNetwork.mainnet: "0x34cc6762780f4f6f153c924c0680cfe2a1fb4601e7d33cc28a92297b62de1e0e",
        KioskNetwork.custom: ""
    ]

    public static func testnetRules() -> [TransferPolicyRule] {
        return Self.getBaseRules(baseRules: BaseRulePackageIds(royaltyRulePackageId: Self.royaltyRuleAddress[KioskNetwork.testnet], kioskLockRulePackageId: Self.kioskLockRuleAddress[KioskNetwork.testnet], personalKioskRulePackageId: Self.personalKioskRuleAddress[KioskNetwork.testnet], floorPriceRulePackageId: Self.floorPriceRuleAddres[KioskNetwork.testnet]))
    }

    public static func mainnetRules() -> [TransferPolicyRule] {
        return Self.getBaseRules(baseRules: BaseRulePackageIds(royaltyRulePackageId: Self.royaltyRuleAddress[KioskNetwork.mainnet], kioskLockRulePackageId: kioskLockRuleAddress[KioskNetwork.mainnet], personalKioskRulePackageId: nil, floorPriceRulePackageId: nil))
    }

    public static func rules() -> [KioskNetwork: [TransferPolicyRule]] {
        return [
            KioskNetwork.testnet: Self.testnetRules(),
            KioskNetwork.mainnet: Self.mainnetRules()
        ]
    }

    /// Constructs a list of rule resolvers based on the params.
    public static func getBaseRules(
        baseRules: BaseRulePackageIds
    ) -> [TransferPolicyRule] {
        var rules: [TransferPolicyRule] = []

        if let royaltyRulePackageId = baseRules.royaltyRulePackageId {
            rules.append(TransferPolicyRule(rule: "\(royaltyRulePackageId)::royalty_rule::Rule", packageId: royaltyRulePackageId, resolveRuleFunction: ResolveRules.resolveRoyaltyRule, hasLockingRule: nil))
        }

        if let kioskLockRulePackageId = baseRules.kioskLockRulePackageId {
            rules.append(TransferPolicyRule(rule: "\(kioskLockRulePackageId)::kiosk_lock_rule::Rule", packageId: kioskLockRulePackageId, resolveRuleFunction: ResolveRules.resolveKisokLockRule, hasLockingRule: true))
        }

        if let personalKioskRulePackageId = baseRules.personalKioskRulePackageId {
            rules.append(TransferPolicyRule(rule: "\(personalKioskRulePackageId)::personal_kiosk_rule::Rule", packageId: personalKioskRulePackageId, resolveRuleFunction: ResolveRules.resolvePersonalKioskRule, hasLockingRule: nil))
        }

        if let floorPriceRulePackageId = baseRules.floorPriceRulePackageId {
            rules.append(TransferPolicyRule(rule: "\(floorPriceRulePackageId)::floor_price_rule::Rule", packageId: floorPriceRulePackageId, resolveRuleFunction: ResolveRules.resolveFloorPriceRule, hasLockingRule: nil))
        }

        return rules
    }
}
