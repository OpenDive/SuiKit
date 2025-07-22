//
//  KioskUtilities.swift
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
public struct KioskUtilities {
    public static let defaultQueryLimit = 50

    public static func getKioskObject(
        client: SuiProvider,
        id: String
    ) async throws -> Kiosk {
        let queryRes = try await client.getObject(
            objectId: id,
            options: SuiObjectDataOptions(
                showBcs: true
            )
        )

        guard let data = queryRes?.data else { throw SuiError.notImplemented }

        guard
            let bcs = data.bcs,
            case .moveObject(let serialziedKiosk) = bcs,
            let kioskData = Data(base64Encoded: serialziedKiosk.bcsBytes)
        else { throw SuiError.customError(
            message: "Invalid Kiosk Data"
        ) }

        let der = Deserializer(data: kioskData)

        return try Kiosk.deserialize(from: der)
    }

    /// Helper to extract kiosk data from dynamic fields.
    public static func extractKioskData(
        data: [DynamicFieldInfo],
        listings: inout [KioskListing],
        lockedItemIds: inout [String],
        kioskId: String
    ) throws -> KioskData {
        var acc = KioskData()
        for val in data {
            let type = val.name.type

            if type.starts(with: "0x2::kiosk::Item") {
                acc.itemIds.append(val.objectId)
                acc.items.append(
                    KioskItem(
                        objectId: val.objectId,
                        type: val.objectType,
                        isLocked: false,
                        listing: nil,
                        kioskId: kioskId,
                        data: nil
                    )
                )
            }

            if type.starts(with: "0x2::kiosk::Listing") {
                acc.listingIds.append(val.objectId)
                listings.append(
                    KioskListing(
                        objectId: val.name.value["id"].stringValue,
                        hasPurchaseCap: val.name.value["is_exclusive"].boolValue,
                        listingId: val.objectId,
                        price: nil
                    )
                )
            }

            if type.starts(with: "0x2::kiosk::Lock") {
                lockedItemIds.append(val.name.value["id"].stringValue)
            }

            if type.starts(with: "0x2::kiosk_extension::ExtensionKey") {
                let type = try StructTag.fromStr(val.name.type).value.typeArgs[0].toString()
                acc.extensions.append(
                    KioskExtensionOverview(
                        objectId: val.objectId,
                        type: type
                    )
                )
            }
        }

        return acc
    }

    /// A helper that attaches the listing prices to kiosk listings.
    public static func attachListingsAndPrices(
        kioskData: inout KioskData,
        listings: [KioskListing],
        listingObjects: [SuiObjectResponse]
    ) {
        var itemListings: [String: KioskListing] = [:]

        // map item listings as {item_id: KioskListing}
        // for easier mapping on the nex
        listings.enumerated().forEach { (idx, listing) in
            itemListings[listing.objectId] = listing
            // return in case we don't have any listing objects.
            // that's the case when we don't have the `listingPrices` included.
            if !listingObjects.isEmpty {
                let content = listingObjects[idx].data?.content
                if
                    let content,
                    case .moveObject(let moveObject) = content,
                    let fields = moveObject.fields {
                    itemListings[listing.objectId]?.price = fields["value"].stringValue
                }
            }
        }

        for var item in kioskData.items {
            item.listing = itemListings[item.objectId]
        }
    }

    /// A helper that attaches the listing prices to kiosk listings.
    public static func attachObjects(kioskData: inout KioskData, objects: [SuiObjectData]) {
        var mapping: [String: SuiObjectData] = [:]

        for object in objects {
            mapping[object.objectId] = object
        }

        for var item in kioskData.items {
            item.data = mapping[item.objectId]
        }
    }

    /// A Helper to attach locked state to items in Kiosk Data.
    public static func attachLockedItems(kioskData: inout KioskData, lockedItemIds: [String]) {
        var lockedStatuses: [String: Bool] = [:]

        // map lock status in an array of type { item_id: true }
        for id in lockedItemIds {
            lockedStatuses[id] = true
        }

        // parse lockedItemIds and attach their locked status.
        for var item in kioskData.items {
            if let status = lockedStatuses[item.objectId] {
                item.isLocked = status
            } else {
                item.isLocked = false
            }
        }
    }

    /**
     * A helper to fetch all DF pages.
     * We need that to fetch the kiosk DFs consistently, until we have
     * RPC calls that allow filtering of Type / batch fetching of spec
     */
    public static func getAllDynamicFields(
        client: SuiProvider,
        parentId: String,
        cursorParam: String? = nil,
        limitParam: Int? = nil
    ) async throws -> [DynamicFieldInfo] {
        var hasNextPage = true
        var cursor: String? = cursorParam
        var data: [DynamicFieldInfo] = []

        while hasNextPage {
            let result = try await client.getDynamicFields(
                parentId: parentId,
                limit: limitParam,
                cursor: cursor
            )
            data.append(contentsOf: result.data)
            hasNextPage = result.hasNextPage
            cursor = result.nextCursor
        }

        return data
    }

    /**
     * A helper to fetch all objects that works with pagination.
     * It will fetch all objects in the array, and limit it to 50/request.
     */
    public static func getAllObjects(
        client: SuiProvider,
        ids: [String],
        options: SuiObjectDataOptions = SuiObjectDataOptions(),
        limit: Int = Self.defaultQueryLimit
    ) async throws -> [SuiObjectResponse] {
        let chunks = stride(from: 0, to: ids.count, by: limit).map {
            Array(ids[$0 ..< min($0 + limit, ids.count)])
        }

        var results: [SuiObjectResponse] = []

        for chunk in chunks {
            let output = try await client.getMultiObjects(ids: chunk, options: options)
            results.append(contentsOf: output)
        }

        return results
    }

    /**
     * A helper to return all owned objects, with an optional filter.
     * It parses all the pages and returns the data.
     */
    public static func getAllOwnedObjects(
        client: SuiProvider,
        owner: String,
        filter: SuiObjectDataFilter? = nil,
        options: SuiObjectDataOptions = SuiObjectDataOptions(showContent: true, showType: true),
        limit: Int = Self.defaultQueryLimit
    ) async throws -> [SuiObjectResponse] {
        var hasNextPage = true
        var cursor: String?
        var data: [SuiObjectResponse] = []

        while hasNextPage {
            let result = try await client.getOwnedObjects(
                owner: owner,
                filter: filter,
                options: options,
                cursor: cursor,
                limit: limit
            )
            data.append(contentsOf: result.data)
            hasNextPage = result.hasNextPage!
            cursor = result.nextCursor
        }

        return data
    }

    /**
     * A helper to parse a transfer policy Cap into a usable object.
     */
    public static func parseTransferPolicyCapObject(
        item: SuiObjectResponse
    ) -> TransferPolicyCap? {
        if case .moveObject(let moveObject) = item.data?.content {
            if let policy = moveObject.fields?["policy_id"].stringValue {
                if let policyCapId = item.data?.objectId {
                    guard moveObject.type.contains(
                        TransferPolicyConstants.transferPolicyCapType
                    ) else { return nil }

                    // Transform 0x2::transfer_policy::TransferPolicyCap<itemType> -> itemType
                    let objectType = String(
                        moveObject.type.replacingOccurrences(
                            of: (TransferPolicyConstants.transferPolicyCapType + "<"),
                            with: ""
                        ).dropLast()
                    )

                    return TransferPolicyCap(
                        policyId: policy,
                        policyCapId: policyCapId,
                        type: objectType
                    )
                }
            }
        }

        return nil
    }

    /// Normalizes the packageId part of a rule's type.
    public static func getNormalizedRuleType(rule: String) throws -> String {
        if #available(macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            var normalizedRuleAddress = rule.split(separator: "::").map { String($0) }
            normalizedRuleAddress[0] = try Inputs.normalizeSuiAddress(value: normalizedRuleAddress[0])
            return normalizedRuleAddress.joined(separator: "::")
        } else {
            throw SuiError.notImplemented
        }
    }
}
