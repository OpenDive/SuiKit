//
//  SuiNSQueries.swift
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

public struct SuiNSQueries {
    /// Get NFT's owner from RPC.
    public static func getOwner(
        client: SuiProvider,
        nftId: String
    ) async throws -> String? {
        let ownerResponse = try await client.getObject(
            objectId: nftId,
            options: SuiObjectDataOptions(
                showOwner: true
            )
        )

        guard let owner = ownerResponse?.data?.owner else { return nil }

        switch owner {
        case .addressOwner(let addressOwner):
            return addressOwner
        case .objectOwner(let objectOwner):
            return objectOwner
        default:
            return nil
        }
    }

    /// Get avatar NFT Object from RPC.
    public static func getAvatar(
        client: SuiProvider,
        avatar: String
    ) async throws -> SuiObjectResponse? {
        return try await client.getObject(
            objectId: avatar,
            options: SuiObjectDataOptions(
                showDisplay: true,
                showOwner: true
            )
        )
    }
}
