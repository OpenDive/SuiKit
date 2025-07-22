//
//  TransferPolicyQuery.swift
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
public struct TransferPolicyQuery {
    /// Searches the `TransferPolicy`-s for the given type. The seach is performed via
    /// the `TransferPolicyCreated` event. The policy can either be owned or shared,
    /// and the caller needs to filter the results accordingly (ie single owner can not
    /// be accessed by anyone but the owner).
    public static func queryTransferPolicy(
        client: SuiProvider,
        type: String
    ) async throws -> [TransferPolicy] {
        let data = try await client.queryEvents(
            query: SuiEventFilter.moveEventType(
                "\(TransferPolicyConstants.transferPolicyCreatedEvent)<\(type)>"
            )
        ).data
        let search = data.map {
            $0.parsedJson["id"].stringValue
        }
        let policies = try await client.getMultiObjects(
            ids: search,
            options: SuiObjectDataOptions(
                showBcs: true,
                showOwner: true
            )
        )
        return try policies.compactMap { $0.data }.compactMap { response in
            if
                let bcsBytes = response.bcs,
                case .moveObject(let rawObj) = bcsBytes,
                let bytes = Data(base64Encoded: rawObj.bcsBytes) {
                let der = Deserializer(data: bytes)
                if let parsed: TransferPolicy = try? Deserializer._struct(der) {
                    return TransferPolicy(
                        id: try AccountAddress.fromHex(response.objectId),
                        type: "\(TransferPolicyConstants.transferPolicyType)<\(type)>",
                        balance: parsed.balance,
                        rules: parsed.rules,
                        owner: response.owner
                    )
                }
            }
            return nil
        }
    }

    /// A function to fetch all the user's kiosk Caps
    /// And a list of the kiosk address ids.
    /// Returns a list of `kioskOwnerCapIds` and `kioskIds`.
    /// Extra options allow pagination.
    /// - Returns: TransferPolicyCap Object ID array, empty if not found.
    public static func queryTransferPolicyCapsByType(
        client: SuiProvider,
        address: String,
        type: String
    ) async throws -> [TransferPolicyCap] {
        let filter: SuiObjectDataFilter = .matchAll(
            [
                .structType(
                    "\(TransferPolicyConstants.transferPolicyCapType)<\(type)>"
                )
            ]
        )

        // fetch owned kiosk caps, paginated.
        let data = try await KioskUtilities.getAllOwnedObjects(
            client: client,
            owner: address,
            filter: filter
        )

        return data.compactMap {
            KioskUtilities.parseTransferPolicyCapObject(
                item: $0
            )
        }
    }

    /// A function to fetch all the user's kiosk Caps
    /// And a list of the kiosk address ids.
    /// Returns a list of `kioskOwnerCapIds` and `kioskIds`.
    /// Extra options allow pagination.
    /// - Returns: TransferPolicyCap Object ID array, empty if not found.
    public static func queryOwnedTransferPolicies(
        client: SuiProvider,
        address: String
    ) async throws -> [TransferPolicyCap] {
        guard address.isValidSuiAddress() else { throw SuiError.customError(
            message: "Invalid Sui address"
        ) }

        let filter: SuiObjectDataFilter = .matchAll(
            [
                .moveModule(
                    MoveModuleFilter(
                        module: "transfer_policy",
                        package: "0x2"
                    )
                )
            ]
        )

        // Fetch all owned kiosk caps, paginated.
        let data = try await KioskUtilities.getAllOwnedObjects(client: client, owner: address, filter: filter)

        var policies: [TransferPolicyCap] = []

        for item in data {
            let data = KioskUtilities.parseTransferPolicyCapObject(item: item)
            if let data { policies.append(data) }
        }

        return policies
    }
}
