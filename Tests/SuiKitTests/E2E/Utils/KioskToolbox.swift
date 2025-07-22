//
//  File.swift
//  
//
//  Created by Marcus Arnett on 12/1/23.
//

import Foundation
import SuiKit

@available(iOS 16.0, *)
internal struct KioskToolbox {
    public let testToolbox: TestToolbox
    public let kioskClient: KioskClient

    func prepareHeroRuleset(heroPackageId: String) async throws {
        let publisher = try await self.testToolbox.getPublisherObject()
        var txb = try TransactionBlock()
        let tpTx = TransferPolicyTransactionClient(params: TransferPolicyTransactionParams(kioskClient: self.kioskClient, cap: nil), transactionBlock: &txb)
        try await tpTx
            .create(params: TransferPolicyBaseParams(type: "\(heroPackageId)::hero::Hero", publisher: .string(publisher)))
            .addLockRule()
            .addFloorPriceRule(minPrice: "1000")
            .addRoyaltyRule(percentageBps: "\(Int(try Double(10.0).percentageToBasisPoints()))", minAmount: "100")
            .addPersonalKioskRule()
            .shareAndTransferCap(address: try self.testToolbox.address())
        let tx_res = try await testToolbox.executeTransactionBlock(txb: &txb)
        _ = try await testToolbox.client.waitForTransaction(tx: tx_res.digest)
    }

    func prepareVillainTransferPolicy(villainPackageId: String) async throws {
        let publisher = try await self.testToolbox.getPublisherObject()
        var txb = try TransactionBlock()
        let tpTx = TransferPolicyTransactionClient(params: TransferPolicyTransactionParams(kioskClient: self.kioskClient, cap: nil), transactionBlock: &txb)

        try await tpTx.createAndShare(params: TransferPolicyBaseParams(type: "\(villainPackageId)::hero::Villain", publisher: .string(publisher)), address: try self.testToolbox.address())
        let tx_res = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res.digest)
    }

    func testLockItemFlow(cap: KioskOwnerCap, itemType: String, itemId: String) async throws {
        var txb = try TransactionBlock()
        let kioskTx = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient, kioskCap: cap)
        let policies = try await self.kioskClient.getTransferPolicies(type: itemType)
        guard policies.count == 1 else { throw SuiError.notImplemented }
        try kioskTx
            .lock(itemType: itemType, itemId: .string(itemId), policy: .string(policies[0].id.hex()))
            .finalize()
        let tx_res = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res.digest)
    }

    func existingKioskManagementFlow(cap: KioskOwnerCap, itemType: String, itemId: String) async throws {
        var txb = try TransactionBlock()
        let kioskTx = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient, kioskCap: cap)
        _ = try kioskTx
            .place(itemType: itemType, item: .string(itemId))
            .list(itemType: itemType, itemId: itemId, price: "100000")
            .delist(itemType: itemType, itemId: itemId)

        let item = try kioskTx.take(itemType: itemType, itemId: itemId)

        try kioskTx
            .placeAndList(itemType: itemType, item: .objectArgument(item), price: "100000")
            .delist(itemType: itemType, itemId: itemId)
            .transfer(itemType: itemType, itemId: itemId, address: try self.testToolbox.address())
            .withdraw(address: try self.testToolbox.address())
            .finalize()
        let tx_res = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res.digest)
    }

    func purchaseFlow(buyerCap: KioskOwnerCap, sellerCap: KioskOwnerCap, itemType: String, itemId: String) async throws {
        let salePrice: UInt64 = 100_000
        var sellTxb = try TransactionBlock()
        let sellKioskTx = try KioskTransactionClient(transactionBlock: &sellTxb, kioskClient: self.kioskClient, kioskCap: sellerCap)
        try sellKioskTx
            .placeAndList(itemType: itemType, item: .string(itemId), price: "\(salePrice)")
            .finalize()
        let tx_res_sell = try await self.testToolbox.executeTransactionBlock(txb: &sellTxb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res_sell.digest)

        var purchaseTxb = try TransactionBlock()
        let purchaseTx = try KioskTransactionClient(transactionBlock: &purchaseTxb, kioskClient: self.kioskClient, kioskCap: buyerCap)
        try await purchaseTx
            .purchaseAndResolve(itemType: itemType, itemId: itemId, price: salePrice, sellerKiosk: .string(sellerCap.kioskId))
            .finalize()
        let tx_res_purchase = try await self.testToolbox.executeTransactionBlock(txb: &purchaseTxb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res_purchase.digest)
    }

    func purchaseOnNewKiosk(sellerCap: KioskOwnerCap, itemType: String, itemId: String, personal: Bool? = nil) async throws {
        let salePrice: UInt64 = 100_000
        var sellTxb = try TransactionBlock()
        let sellKioskTx = try KioskTransactionClient(transactionBlock: &sellTxb, kioskClient: self.kioskClient, kioskCap: sellerCap)
        try sellKioskTx
            .placeAndList(itemType: itemType, item: .string(itemId), price: "\(salePrice)")
            .finalize()
        let tx_res_sell = try await self.testToolbox.executeTransactionBlock(txb: &sellTxb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res_sell.digest)

        var purchaseTxb = try TransactionBlock()
        let purchaseTx = try KioskTransactionClient(transactionBlock: &purchaseTxb, kioskClient: self.kioskClient, kioskCap: nil)

        if personal != nil, personal! { _ = try purchaseTx.createPersonal(borrow: true) } else { _ = try purchaseTx.create() }

        _ = try await purchaseTx.purchaseAndResolve(itemType: itemType, itemId: itemId, price: salePrice, sellerKiosk: .string(sellerCap.kioskId))
        if personal == nil || (personal != nil && !(personal!)) { try purchaseTx.shareAndTransferCap(address: try self.testToolbox.address()) }
        try purchaseTx.finalize()
        let tx_res_purchase = try await self.testToolbox.executeTransactionBlock(txb: &purchaseTxb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res_purchase.digest)
    }

    func publishHeroPackage() async throws -> String {
        let result = try await self.testToolbox.publishPackage("hero")
        return result.packageId
    }

    func createKiosk() async throws {
        var txb = try TransactionBlock()
        let kioskTxClient = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient)
        try kioskTxClient.createAndShare(address: try self.testToolbox.address())
        let tx_res = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res.digest)
    }

    func createPersonalKiosk() async throws {
        var txb = try TransactionBlock()
        let kioskTxClient = try KioskTransactionClient(transactionBlock: &txb, kioskClient: self.kioskClient)
        try kioskTxClient
            .createPersonal()
            .finalize()
        let tx_res = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        _ = try await self.testToolbox.client.waitForTransaction(tx: tx_res.digest)
    }

    func mintHero(packageId: String) async throws -> String {
        var txb = try TransactionBlock()
        let hero = try txb.moveCall(target: "\(packageId)::hero::mint_hero")
        _ = try txb.transferObject(objects: hero, address: try self.testToolbox.address())
        var result = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        let digest = result.digest
        result = try await self.testToolbox.client.waitForTransaction(tx: digest, options: SuiTransactionBlockResponseOptions(showEffects: true, showEvents: true, showObjectChanges: true))
        return try self.testToolbox.getCreatedObjectIdByType(res: result, type: "hero::Hero")
    }

    func mintVillain(packageId: String) async throws -> String {
        var txb = try TransactionBlock()
        let villain = try txb.moveCall(target: "\(packageId)::hero::mint_villain")
        _ = try txb.transferObject(objects: villain, address: try self.testToolbox.address())
        var result = try await self.testToolbox.executeTransactionBlock(txb: &txb)
        let digest = result.digest
        result = try await self.testToolbox.client.waitForTransaction(tx: digest, options: SuiTransactionBlockResponseOptions(showEffects: true, showEvents: true, showObjectChanges: true))
        return try self.testToolbox.getCreatedObjectIdByType(res: result, type: "hero::Villain")
    }
}
