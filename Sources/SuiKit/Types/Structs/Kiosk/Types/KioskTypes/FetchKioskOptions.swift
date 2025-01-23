//
//  FetchKioskOptions.swift
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

public struct FetchKioskOptions {
    /// Include the base kiosk object, which includes the profits, the owner and the base fields.
    public var withKioskFields: Bool

    /// Include the listing prices.
    public var withListingPrices: Bool

    /// Include the objects for the Items in the kiosk. Defaults to `display` only.
    public var withObjects: Bool

    /// Pass the data options for the objects, when fetching, in case you want to query other details.
    public var objectOptions: SuiObjectDataOptions

    public init(
        withKioskFields: Bool = false,
        withListingPrices: Bool = false,
        withObjects: Bool = false,
        objectOptions: SuiObjectDataOptions = SuiObjectDataOptions(showContent: true)
    ) {
        self.withKioskFields = withKioskFields
        self.withListingPrices = withListingPrices
        self.withObjects = withObjects
        self.objectOptions = objectOptions
    }
}
