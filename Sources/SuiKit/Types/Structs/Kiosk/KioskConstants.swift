//
//  KioskConstants.swift
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

public struct KioskConstants {
    /// The Kiosk module.
    public static let kioskModule = "0x2::kiosk"

    /// The Kiosk type.
    public static let kioskType = "\(kioskModule)::Kiosk"

    /// The Kiosk Owner Cap Type
    public static let kioskOwnerCap = "\(kioskModule)::KioskOwnerCap"

    /// The Kiosk Item Type
    public static let kioskItem = "\(kioskModule)::KioskItem"

    /// The Kiosk Listing Type
    public static let kioskListing = "\(kioskModule)::KioskListing"

    /// The Kiosk Lock Type
    public static let kioskLock = "\(kioskModule)::KioskLock"

    /// The Kiosk PurchaseCap type
    public static let kioskPurchaseCap = "\(kioskModule)::PurchaseCap"
}
