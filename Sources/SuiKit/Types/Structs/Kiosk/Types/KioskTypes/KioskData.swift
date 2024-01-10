//
//  KioskData.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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
 * Aggregated data from the Kiosk.
 */
public struct KioskData {
    public var items: [KioskItem]
    public var itemIds: [String]
    public var listingIds: [String]
    public var kiosk: Kiosk?
    public var extensions: [KioskExtensionOverview]  // Type will be defined on later versions of the SDK.

    public init(
        items: [KioskItem] = [],
        itemIds: [String] = [],
        listingIds: [String] = [],
        kiosk: Kiosk? = nil,
        extensions: [KioskExtensionOverview] = []
    ) {
        self.items = items
        self.itemIds = itemIds
        self.listingIds = listingIds
        self.kiosk = kiosk
        self.extensions = extensions
    }
}