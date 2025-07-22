//
//  KioskTest.swift
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
import XCTest
@testable import SuiKit

@available(iOS 16.0, *)
final class KioskTest: XCTestCase {
    var toolBox: TestToolbox?
    var kioskToolbox: KioskToolbox?
    var extensionsPackageId: String?
    var heroPackageId: String?
    var kioskClient: KioskClient?
    var heroType: String?
    var villainType: String?

    override func setUp() async throws {
        self.toolBox = try await TestToolbox(true)
        self.extensionsPackageId = try await self.toolBox!.publishKioskExtensions()
        self.kioskClient = KioskClient(client: self.toolBox!.client, network: .custom, packageIds: BaseRulePackageIds(royaltyRulePackageId: self.extensionsPackageId, kioskLockRulePackageId: self.extensionsPackageId, personalKioskRulePackageId: self.extensionsPackageId, floorPriceRulePackageId: self.extensionsPackageId))
        self.kioskToolbox = KioskToolbox(testToolbox: self.toolBox!, kioskClient: self.kioskClient!)
        self.heroPackageId = try await self.kioskToolbox!.publishHeroPackage()
        self.heroType = "\(self.heroPackageId!)::hero::Hero"
        self.villainType = "\(self.heroPackageId!)::hero::Villain"

        try await self.kioskToolbox!.prepareHeroRuleset(heroPackageId: self.heroPackageId!)
        try await self.kioskToolbox!.prepareVillainTransferPolicy(villainPackageId: self.heroPackageId!)
        try await self.kioskToolbox!.createKiosk()
        try await self.kioskToolbox!.createPersonalKiosk()
    }

    func testThatPersonalKioskFunctionsWillExecuteAsIntended() async throws {
        let heroId = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)
        let heroId2 = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)

        let kioskOwnerCaps = try await self.kioskToolbox!.kioskClient.getOwnedKiosks(address: try self.toolBox!.address()).kioskOwnerCaps
        XCTAssertEqual(kioskOwnerCaps.count, 2)

        let normalKiosk = kioskOwnerCaps.filter { $0.isPersonal != nil && !($0.isPersonal!) }[0]
        let personalKiosk = kioskOwnerCaps.filter { $0.isPersonal != nil && $0.isPersonal! }[0]

        // test non personal
        try await self.kioskToolbox!.existingKioskManagementFlow(cap: normalKiosk, itemType: self.heroType!, itemId: heroId)

        // test personal kiosk
        try await self.kioskToolbox!.existingKioskManagementFlow(cap: personalKiosk, itemType: self.heroType!, itemId: heroId2)
    }

    func testThatLockingOnKioskFunctionsWillWorkAsIntended() async throws {
        let heroId = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)
        let heroId2 = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)

        let kioskOwnerCaps = try await self.kioskToolbox!.kioskClient.getOwnedKiosks(address: try self.toolBox!.address()).kioskOwnerCaps

        try await self.kioskToolbox!.testLockItemFlow(cap: kioskOwnerCaps.filter { $0.isPersonal != nil && !($0.isPersonal!) }[0], itemType: self.heroType!, itemId: heroId)

        try await self.kioskToolbox!.testLockItemFlow(cap: kioskOwnerCaps.filter { $0.isPersonal != nil && ($0.isPersonal!) }[0], itemType: self.heroType!, itemId: heroId2)
    }

    func testThatItemManipulationForKiosksWorksAsIntended() async throws {
        let heroId = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)
        let kioskOwnerCaps = try await self.kioskToolbox!.kioskClient.getOwnedKiosks(address: try self.toolBox!.address()).kioskOwnerCaps

        var txb = try TransactionBlock()
        let kioskTx = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient!, kioskCap: kioskOwnerCaps[0])

        _ = try kioskTx.place(itemType: self.heroType!, item: .string(heroId))
        let (item, promise) = try kioskTx.borrow(itemType: self.heroType!, itemId: heroId)

        _ = try txb.moveCall(target: "\(self.heroPackageId!)::hero::level_up", arguments: [item])
        try kioskTx.returnValue(itemType: self.heroType!, item: item, promise: promise)

        // Let's try to increase health again by using callback style borrow
        try kioskTx.borrowTx(itemType: self.heroType!, itemId: heroId) { argument in
            _ = try txb.moveCall(target: "\(self.heroPackageId!)::hero::level_up", arguments: [argument])
        }

        try kioskTx.finalize()
        _ = try await self.toolBox!.executeTransactionBlock(txb: &txb)
    }

    func testThatPurchasingAndResolvingItemsUnderAllRuleSetsWorksAsIntended() async throws {
        let heroId = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)
        let kioskOwnerCaps = try await self.kioskToolbox!.kioskClient.getOwnedKiosks(address: try self.toolBox!.address()).kioskOwnerCaps

        let normalKiosk = kioskOwnerCaps.filter { $0.isPersonal != nil && !($0.isPersonal!) }[0]
        let personalKiosk = kioskOwnerCaps.filter { $0.isPersonal != nil && $0.isPersonal! }[0]

        try await self.kioskToolbox!.purchaseFlow(buyerCap: personalKiosk, sellerCap: normalKiosk, itemType: self.heroType!, itemId: heroId)
    }

    func testThatShouldPurchaseInANewKioskFromAPersonalKioskAndResolvePersonalKioskRuleAsIntended() async throws {
        let heroId = try await self.kioskToolbox!.mintHero(packageId: self.heroPackageId!)
        let villainId = try await self.kioskToolbox!.mintVillain(packageId: self.heroPackageId!)  // Minting a villain who has no transfer policy rules so we can buy from a new kiosk.

        let kioskOwnerCaps = try await self.kioskToolbox!.kioskClient.getOwnedKiosks(address: try self.toolBox!.address()).kioskOwnerCaps
        let personalKiosk = kioskOwnerCaps.filter { $0.isPersonal != nil && $0.isPersonal! }[0]

        try await self.kioskToolbox!.purchaseOnNewKiosk(sellerCap: personalKiosk, itemType: self.heroType!, itemId: heroId, personal: true)
        try await self.kioskToolbox!.purchaseOnNewKiosk(sellerCap: personalKiosk, itemType: self.villainType!, itemId: villainId, personal: false)
    }

    func testThatQueryingAKioskShouldHaveTheRightAmounts() async throws {
        let allCaps = try await self.kioskClient!.getOwnedTransferPolicies(address: try self.toolBox!.address())
        XCTAssertEqual(allCaps.count, 2)

        let heroPolicyCaps = try await self.kioskClient!.getOwnedTransferPoliciesByType(type: self.heroType!, address: try self.toolBox!.address())
        XCTAssertEqual(heroPolicyCaps.count, 1)

        let villainPolicyCaps = try await self.kioskClient!.getOwnedTransferPoliciesByType(type: self.villainType!, address: try self.toolBox!.address())
        XCTAssertEqual(villainPolicyCaps.count, 1)
    }

    func testThatManagingATransferPolicyWorksAsIntended() async throws {
        let villainPolicyCaps = try await self.kioskClient!.getOwnedTransferPoliciesByType(type: self.villainType!, address: try self.toolBox!.address())
        var txb = try TransactionBlock()
        let tpTx = TransferPolicyTransactionClient(params: TransferPolicyTransactionParams(kioskClient: self.kioskClient!, cap: villainPolicyCaps[0]), transactionBlock: &txb)

        _ = try tpTx
            .addFloorPriceRule(minPrice: "10")
            .addLockRule()
            .addRoyaltyRule(percentageBps: "\(try (10.0).percentageToBasisPoints())", minAmount: "0")
            .addPersonalKioskRule()
            .removeFloorPriceRule()
            .removeLockRule()
            .removeRoyaltyRule()
            .removePersonalKioskRule()
            .withdraw(address: try self.toolBox!.address())

        _ = try await self.toolBox!.executeTransactionBlock(txb: &txb)
    }

    func testThatFetchingKiosksByIdWorksAsIntended() async throws {
        let kioskOwnerCaps = try await self.kioskToolbox!.kioskClient.getOwnedKiosks(address: try self.toolBox!.address()).kioskOwnerCaps

        let kiosk = try await self.kioskClient!.getKiosk(id: kioskOwnerCaps[0].kioskId, options: FetchKioskOptions(withKioskFields: true, withListingPrices: true, withObjects: true, objectOptions: SuiObjectDataOptions(showContent: true, showDisplay: true)))
        XCTAssertNotNil(kiosk.kiosk)
        XCTAssertEqual(try Inputs.normalizeSuiAddress(value: kiosk.kiosk!.owner.hex()), try self.toolBox!.address())
    }

    func testThatVerifiesAnErrorGetsThrownWhenTryingToCallAnyFunctionAfterCallingFinalize() async throws {
        func throwingFinalize() throws {
            var txb = try TransactionBlock()
            let kioskTx = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient!)
            _ = try kioskTx
                .createPersonal()
                .finalize()

            _ = try kioskTx.withdraw(address: try self.toolBox!.address())  // Should throw an error
        }

        XCTAssertThrowsError(try throwingFinalize())
    }
}
