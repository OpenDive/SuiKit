//
//  SuiNSParser.swift
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

public struct SuiNSParser {
    public static func camelCase(_ string: String) -> String {
        let pattern = "(_\\w)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.utf16.count)

        return regex.stringByReplacingMatches(
            in: string,
            options: [],
            range: range,
            withTemplate: "$1"
        ).replacingOccurrences(of: "_", with: "").capitalizingFirstLetter()
    }

    public static func parseObjectDataResponse(response: SuiObjectResponse) -> [String: JSON]? {
        if let data = response.data {
            if case .moveObject(let moveObject) = data.content {
                if let fieldMap = moveObject.fields?.dictionaryValue {
                    return fieldMap
                }
            }
        }
        return nil
    }

    public static func parseRegistryResponse(response: SuiObjectResponse) -> NameObject? {
        guard let fields = Self.parseObjectDataResponse(response: response) else { return nil }

        var result: [String: JSON] = [:]

        if let value = fields["value"], let id = fields["id"] {
            for content in value["fields"]["data"]["fields"]["contents"].arrayValue {
                let key = content["fields"]["key"].stringValue
                let value = content["fields"]["value"]
                let normalizedAddress = try? Inputs.normalizeSuiAddress(value: value.stringValue)

                result[key] =  (content["type"].stringValue.contains("Address") || key == "addr") ? JSON(normalizedAddress!) : value
            }

            return NameObject(
                id: response.data?.objectId ?? id["id"].stringValue,
                owner: value["fields"]["target_address"].stringValue,
                targetAddress: value["fields"]["target_address"].stringValue,
                avatar: result["avatar"]?.string,
                contentHash: result["content_hash"]?.string,
                nftId: value["fields"]["nft_id"].string,
                expirationTimestampMs: value["fields"]["expiration_timestamp_ms"].stringValue
            )
        }

        return nil
    }
}
