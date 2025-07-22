//
//  KioskClient.swift
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

/**
 * A Client that allows you to interact with kiosk.
 * Offers utilities to query kiosk, craft transactions to edit your own kiosk,
 * purchase, manage transfer policies, create new kiosks etc.
 * If you pass packageIds, all functionality will be managed using these packages.
 */
@available(iOS 16.0, *)
public class KioskClient {
    let client: SuiProvider
    let network: KioskNetwork
    let rules: [TransferPolicyRule]
    let packageIds: BaseRulePackageIds?

    public init(
        client: SuiProvider,
        network: KioskNetwork,
        rules: [TransferPolicyRule] = [],
        packageIds: BaseRulePackageIds? = nil
    ) {
        var resultRules = rules

        self.client = client
        self.network = network
        self.packageIds = packageIds

        // Add the custom Package Ids too on the rule list.
        // Only adds the rules that are passed in the packageId object.
        if let packageIds {
            resultRules.append(
                contentsOf: RuleAddresses.getBaseRules(
                    baseRules: packageIds  // add all the default rules.
                )
            )
        }

        self.rules = resultRules
    }

    // MARK: Querying

    /// Get an addresses's owned kiosks.
    /// - Parameter address: The address for which we want to retrieve the kiosks.
    /// - Returns: An Object containing all the `kioskOwnerCap` objects as well as the kioskIds.
    public func getOwnedKiosks(address: String) async throws -> OwnedKiosks {
        let personalPackageId =
            self.packageIds?.personalKioskRulePackageId ??
            RuleAddresses.personalKioskRuleAddress[self.network]
        return try await KioskQuery.getOwnedKiosks(
            client: self.client,
            address: address,
            personalKioskType: personalPackageId != nil ?
                "\(personalPackageId!)::personal_kiosk::PersonalKioskCap" :
                ""
        )
    }

    /// Fetches the kiosk contents.
    /// - Parameters:
    ///   - id: The ID of the kiosk to fetch.
    ///   - options: Options pertaining to fetching Kiosks
    /// - Returns: `KioskData` object
    public func getKiosk(
        id: String,
        options: FetchKioskOptions = FetchKioskOptions()
    ) async throws -> KioskData {
        return (
            try await KioskQuery.fetchKiosk(
                client: self.client,
                kioskId: id,
                limit: 100,
                options: options
            )
        ).data
    }

    /// Fetch the extension data (if any) for a kiosk, by type
    /// - Parameters:
    ///   - kioskId: The ID of the kiosk to lookup
    ///   - type: The type of Kiosk Extension
    /// - Returns: The Type of the extension (can be used from by using the type returned by `getKiosk()`)
    public func getKioskExtension(
        kioskId: String,
        type: String
    ) async throws -> KioskExtension? {
        return try await KioskQuery.fetchKioskExtension(
            client: self.client,
            kioskId: kioskId,
            extensionType: type
        )
    }

    /// Query the Transfer Policy(ies) for type `T`.
    /// - Parameter type: type The Type we're querying for (E.g `0xMyAddress::hero::Hero`)
    /// - Returns: An array of `TransferPolicy` objects
    public func getTransferPolicies(type: String) async throws -> [TransferPolicy] {
        return try await TransferPolicyQuery.queryTransferPolicy(
            client: self.client,
            type: type
        )
    }

    /// Query all the owned transfer policies for an address.
    /// - Parameter address: The address we're searching the owned transfer policies for.
    /// - Returns: `TransferPolicyCap` which uncludes `policyId` and `policyCapId`, types.
    public func getOwnedTransferPolicies(address: String) async throws -> [TransferPolicyCap] {
        return try await TransferPolicyQuery.queryOwnedTransferPolicies(
            client: self.client,
            address: address
        )
    }

    /// Query the Transfer Policy Cap for type `T`, owned by `address`
    /// - Parameters:
    ///   - type: The Type `T` for the object
    ///   - address: The address that owns the cap.
    /// - Returns: An array of `TransferPolicyCap` objects
    public func getOwnedTransferPoliciesByType(
        type: String,
        address: String
    ) async throws -> [TransferPolicyCap] {
        return try await TransferPolicyQuery.queryTransferPolicyCapsByType(
            client: self.client,
            address: address,
            type: type
        )
    }

    /// A convenient helper to get the packageIds for our supported ruleset, based on `kioskClient` configuration.
    public func getRulePackageId(rule: RulePackage) throws -> String {
        guard let rules = self.packageIds else { throw SuiError.notImplemented }
        return rules.getRule(rule: rule, network: self.network)
    }
}
