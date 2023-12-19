//
//  File.swift
//  
//
//  Created by Marcus Arnett on 12/1/23.
//

import Foundation
import SuiKit

internal struct KioskToolbox {
    public let testToolbox: TestToolbox
    public let kioskClient: KioskClient
    
    func prepareHeroRuleset(heroPackageId: String) async throws {
        let publisher = try await self.testToolbox.getPublisherObject()
        var txb = try TransactionBlock()
        let tpTx = TransferPolicyTransactionClient(params: TransferPolicyTransactionParams(kioskClient: self.kioskClient, cap: nil), transactionBlock: &txb)
        try await tpTx.create(params: TransferPolicyBaseParams(type: "\(heroPackageId)::hero::Hero", publisher: .string(publisher)))
        try tpTx.addLockRule()
        try tpTx.addFloorPriceRule(minPrice: "1000")
        try tpTx.addRoyaltyRule(percentageBps: "\(Int(try Double(10.0).percentageToBasisPoints()))", minAmount: "100")
        try tpTx.addPersonalKioskRule()
        try await tpTx.shareAndTransferCap(address: try self.testToolbox.address())
        let _ = try await testToolbox.executeTransactionBlock(txb: &txb)
    }

    func prepareVillainTransferPolicy(villainPackageId: String) async throws {
        let publisher = try await self.testToolbox.getPublisherObject()
        var txb = try TransactionBlock()
        let tpTx = TransferPolicyTransactionClient(params: TransferPolicyTransactionParams(kioskClient: self.kioskClient, cap: nil), transactionBlock: &txb)

        try await tpTx.createAndShare(params: TransferPolicyBaseParams(type: "\(villainPackageId)::hero::Villain", publisher: .string(publisher)), address: try self.testToolbox.address())
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &txb)
    }

    func testLockItemFlow(cap: KioskOwnerCap, itemType: String, itemId: String) async throws {
        var txb = try TransactionBlock()
        let kioskTx = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient, kioskCap: cap)
        let policies = try await self.kioskClient.getTransferPolicies(type: itemType)
        guard policies.count == 1 else { throw SuiError.notImplemented }
        try kioskTx.lock(itemType: itemType, itemId: .string(itemId), policy: .string(policies[0].id.hex()))
        try kioskTx.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &txb)
    }

    func existingKioskManagementFlow(cap: KioskOwnerCap, itemType: String, itemId: String) async throws {
        var txb = try TransactionBlock()
        let kioskTx = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient, kioskCap: cap)
        try kioskTx.place(itemType: itemType, item: .string(itemId))
        try kioskTx.list(itemType: itemType, itemId: itemId, price: "100000")
        try kioskTx.delist(itemType: itemType, itemId: itemId)
        let item = try kioskTx.take(itemType: itemType, itemId: itemId)
        try kioskTx.placeAndList(itemType: itemType, item: .objectArgument(item), price: "100000")
        try kioskTx.delist(itemType: itemType, itemId: itemId)
        try kioskTx.transfer(itemType: itemType, itemId: itemId, address: try self.testToolbox.address())
        try kioskTx.withdraw(address: try self.testToolbox.address())
        try kioskTx.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &txb)
    }

    func purchaseFlow(buyerCap: KioskOwnerCap, sellerCap: KioskOwnerCap, itemType: String, itemId: String) async throws {
        let salePrice: UInt64 = 100_000
        var sellTxb = try TransactionBlock()
        let sellKioskTx = try KioskTransactionClient(transactionBlock: &sellTxb, kioskClient: self.kioskClient, kioskCap: sellerCap)
        try sellKioskTx.placeAndList(itemType: itemType, item: .string(itemId), price: "\(salePrice)")
        try sellKioskTx.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &sellTxb)
        
        var purchaseTxb = try TransactionBlock()
        let purchaseTx = try KioskTransactionClient(transactionBlock: &purchaseTxb, kioskClient: self.kioskClient, kioskCap: buyerCap)
        try await purchaseTx.purchaseAndResolve(itemType: itemType, itemId: itemId, price: salePrice, sellerKiosk: .string(sellerCap.kioskId))
        try purchaseTx.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &purchaseTxb)
    }

    func purchaseOnNewKiosk(sellerCap: KioskOwnerCap, itemType: String, itemId: String, personal: Bool? = nil) async throws {
        let salePrice: UInt64 = 100_000
        var sellTxb = try TransactionBlock()
        let sellKioskTx = try KioskTransactionClient(transactionBlock: &sellTxb, kioskClient: self.kioskClient, kioskCap: sellerCap)
        try sellKioskTx.placeAndList(itemType: itemType, item: .string(itemId), price: "\(salePrice)")
        try sellKioskTx.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &sellTxb)
        
        var purchaseTxb = try TransactionBlock()
        let purchaseTx = try KioskTransactionClient(transactionBlock: &purchaseTxb, kioskClient: self.kioskClient, kioskCap: nil)
        
        if personal != nil, personal! { try purchaseTx.createPersonal(borrow: true) }
        else { try purchaseTx.create() }
        
        try await purchaseTx.purchaseAndResolve(itemType: itemType, itemId: itemId, price: salePrice, sellerKiosk: .string(sellerCap.kioskId))
        if personal == nil || (personal != nil && !(personal!)) { try purchaseTx.shareAndTransferCap(address: try self.testToolbox.address()) }
        try purchaseTx.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &purchaseTxb)
    }

    func publishHeroPackage() async throws -> String {
        let result = try await self.testToolbox.publishPackage("hero")
        return result.packageId
    }
    
    func createKiosk() async throws {
        var txb = try TransactionBlock()
        let kioskTxClient = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient)
        try kioskTxClient.createAndShare(address: try self.testToolbox.address())
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &txb)
    }

    func createPersonalKiosk() async throws {
        var txb = try TransactionBlock()
        let kioskTxClient = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient)
        try kioskTxClient.createPersonal()
        try kioskTxClient.finalize()
        let _ = try await self.testToolbox.executeTransactionBlock(txb: &txb)
    }

    func mintHero(packageId: String) async throws -> String {
        var txb = try TransactionBlock()
        let hero = try txb.moveCall(target: "\(packageId)::hero::mint_hero")
        let _ = try txb.transferObject(objects: hero, address: try self.testToolbox.address())
        let result = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        return try self.testToolbox.getCreatedObjectIdByType(res: result, type: "hero::Hero")
    }

    func mintVillain(packageId: String) async throws -> String {
        var txb = try TransactionBlock()
        let villain = try txb.moveCall(target: "\(packageId)::hero::mint_villain")
        let _ = try txb.transferObject(objects: villain, address: try self.testToolbox.address())
        let result = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        return try self.testToolbox.getCreatedObjectIdByType(res: result, type: "hero::Villain")
    }
}
