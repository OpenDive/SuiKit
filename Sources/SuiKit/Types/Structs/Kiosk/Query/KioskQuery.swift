//
//  KioskQuery.swift
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
import SwiftyJSON

@available(iOS 16.0, *)
public struct KioskQuery {
    public static func fetchKiosk(
        client: SuiProvider,
        kioskId: String,
        cursor: String? = nil,
        limit: Int? = nil,
        options: FetchKioskOptions = FetchKioskOptions()
    ) async throws -> PagedKioskData {
        // TODO: Replace the `getAllDynamicFields` with a paginated response, once we have better RPC support for
        // TODO: type filtering & batch fetching. This can't work with pagination currently.
        let data = try await KioskUtilities.getAllDynamicFields(
            client: client,
            parentId: kioskId,
            cursorParam: cursor,
            limitParam: limit
        )

        var listings: [KioskListing] = []
        var lockedItemIds: [String] = []

        // Extracted kiosk data.
        var kioskData = try KioskUtilities.extractKioskData(
            data: data,
            listings: &listings,
            lockedItemIds: &lockedItemIds,
            kioskId: kioskId
        )

        // For items, we usually seek the Display.
        // For listings we usually seek the DF value (price) / exclusivity.
        let kiosk: Kiosk? = options.withKioskFields ?
            try await KioskUtilities.getKioskObject(
                client: client,
                id: kioskId
            ) :
            nil

        let listingObjects: [SuiObjectResponse] = options.withListingPrices ?
            try await KioskUtilities.getAllObjects(
                client: client,
                ids: kioskData.listingIds,
                options: SuiObjectDataOptions(
                    showContent: true
                )
            ) :
            []

        let items: [SuiObjectResponse] = options.withObjects ?
            try await KioskUtilities.getAllObjects(
                client: client,
                ids: kioskData.itemIds,
                options: options.objectOptions
            ) :
            []

        if options.withKioskFields { kioskData.kiosk = kiosk }

        // Attach items listings. IF we have `options.withListingPrices === true`, it will also attach the prices.
        KioskUtilities.attachListingsAndPrices(
            kioskData: &kioskData,
            listings: listings,
            listingObjects: listingObjects
        )

        // Add `locked` status to items that are locked.
        KioskUtilities.attachLockedItems(
            kioskData: &kioskData,
            lockedItemIds: lockedItemIds
        )

        // Attach the objects for the queried items.
        KioskUtilities.attachObjects(
            kioskData: &kioskData,
            objects: items.compactMap { $0.data }
        )

        return PagedKioskData(
            data: kioskData,
            nextCursor: nil,
            hasNextPage: false
        )
    }

    /// A function to fetch all the user's kiosk Caps
    /// And a list of the kiosk address ids.
    /// Returns a list of `kioskOwnerCapIds` and `kioskIds`.
    /// Extra options allow pagination.
    public static func getOwnedKiosks(
        client: SuiProvider,
        address: String,
        cursor: String? = nil,
        limit: Int? = nil,
        personalKioskType: String? = nil
    ) async throws -> OwnedKiosks {
        var anyFilter: [SuiObjectDataFilter] = [
            .structType(KioskConstants.kioskOwnerCap)
        ]
        if let personalKioskType {
            anyFilter.append(.structType(personalKioskType))
        }
        let filter: SuiObjectDataFilter = .matchAny(anyFilter)

        // Fetch owned kiosk caps, paginated.
        let fetchedOwnedKioskCaps = try await client.getOwnedObjects(
            owner: address,
            filter: filter,
            options: SuiObjectDataOptions(
                showContent: true,
                showType: true
            ),
            cursor: cursor,
            limit: limit
        )

        // Get kioskIds from the OwnerCaps.
        let kioskIdList = fetchedOwnedKioskCaps.data.compactMap { kioskCap in
            if case .moveObject(let obj) = kioskCap.data?.content, let fields = obj.fields {
                return fields["cap"]["fields"]["for"].string ?? fields["for"].stringValue
            }
            return nil
        }

        // clean up data that might have an error in them.
        // only return valid objects.
        let filteredData = fetchedOwnedKioskCaps.data.compactMap { $0.data }

        let ownerCaps = filteredData.enumerated().map {
            KioskOwnerCap(
                isPersonal: $0.element.type != KioskConstants.kioskOwnerCap,
                objectId: $0.element.objectId,
                kioskId: kioskIdList[$0.offset],
                digest: $0.element.digest,
                version: $0.element.version
            )
        }

        return OwnedKiosks(
            kioskOwnerCaps: ownerCaps,
            kioskIds: kioskIdList,
            nextCursor: fetchedOwnedKioskCaps.nextCursor,
            hasNextPage: fetchedOwnedKioskCaps.hasNextPage!
        )
    }

    /// Get a kiosk extension data for a given kioskId and extensionType.
    public static func fetchKioskExtension(
        client: SuiProvider,
        kioskId: String,
        extensionType: String
    ) async throws -> KioskExtension? {
        let returnedExtension = try await client.getDynamicFieldObject(
            parentId: kioskId,
            name: DynamicFieldName(
                type: "0x2::kiosk_extension::ExtensionKey<\(extensionType)>",
                value: JSON(["dummy_field": false])
            )
        )

        guard let data = returnedExtension?.data else { return nil }

        guard
            case .moveObject(let obj) = data.content,
            let fields = obj.fields?["value"]["fields"]
        else { return nil }

        return KioskExtension(
            objectId: data.objectId,
            type: extensionType,
            isEnabled: fields["is_enabled"].boolValue,
            permissions: fields["permissions"].stringValue,
            storageId: fields["storage"]["fields"]["id"]["id"].stringValue,
            storageSize: fields["storage"]["fields"]["size"].intValue
        )
    }
}
