//
//  HomeViewModel.swift
//  SuiKit
//
//  Copyright (c) 2024 OpenDive
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
import SuiKit
import Bip39
import SwiftyJSON

public class HomeViewModel: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var currentWallet: Wallet
    @Published var walletAddress: String = ""
    @Published var collectionId: String = ""

    public let restClient = SuiProvider(connection: DevnetConnection())
    public let faucetClient = FaucetClient(connection: DevnetConnection())

    public init(_ mnemos: [[String]]? = nil) throws {
        if let mnemos {
            var tmpWallets: [Wallet] = []
            var lastWallet: Wallet? = nil
            for mnemo in mnemos {
                let newWallet = try Wallet(mnemonic: Mnemonic(mnemonic: mnemo))
                tmpWallets.append(newWallet)
                lastWallet = newWallet
            }
            self.wallets = tmpWallets
            self.currentWallet = lastWallet!
        } else {
            let newWallet = try Wallet()
            self.currentWallet = newWallet
            self.wallets = [newWallet]
        }
        self.walletAddress = try self.currentWallet.accounts[0].address()
    }

    public init(wallet: Wallet) {
        self.currentWallet = wallet
        self.wallets = [wallet]
    }

    public func createWallet() throws {
        let mnemo = try Mnemonic()
        try self.initializeWallet(mnemo)
    }

    public func restoreWallet(_ phrase: String) throws {
        let mnemo = try Mnemonic(mnemonic: phrase.components(separatedBy: " "))
        try self.initializeWallet(mnemo)
    }

    public func getWalletAddresses() throws -> [String] {
        return try self.wallets.map { try $0.accounts[0].address() }
    }

    public func getCurrentWalletAddress() throws -> String {
        return try self.currentWallet.accounts[0].address()
    }

    public func getCurrentWalletBalance() async throws -> Double {
        return (Double(try await self.restClient.getBalance(account: self.currentWallet.accounts[0].publicKey).totalBalance) ?? 0) / Double(1_000_000_000)
    }

    public func airdropToCurrentWallet() async throws {
        let _ = try await self.faucetClient.funcAccount(try self.currentWallet.accounts[0].address())
    }

    public func createNft(
        _ name: String,
        _ objectId: String,
        _ description: String,
        _ url: String
    ) async throws -> String? {
        let coins = try await self.restClient.getCoins(account: try self.currentWallet.accounts[0].address())
        if !coins.data.isEmpty {
            var tx = try TransactionBlock()
            let txArguments: [String] = [
                name,
                description,
                url
            ]
            let _ = try tx.moveCall(
                target: "\(objectId)::devnet_nft::mint",
                arguments: txArguments.map { .input(try tx.pure(value: .string($0))) }
            )
            let options = SuiTransactionBlockResponseOptions(showEffects: true)
            var result = try await self.restClient.signAndExecuteTransactionBlock(
                transactionBlock: &tx,
                signer: self.currentWallet.accounts[0],
                options: options
            )
            result = try await self.restClient.waitForTransaction(tx: result.digest, options: options)
            return result.digest
        }
        return nil
    }

    public func fetchObjectId() -> String {
        return self.collectionId
    }

    public func createCollection() async throws {
        guard let fileUrl = Bundle.main.url(forResource: "Package", withExtension: "json") else {
            throw NSError(domain: "package is missing", code: -1)
        }
        guard let fileCompiledData = try? Data(contentsOf: fileUrl) else {
            throw NSError(domain: "package is corrupted", code: -1)
        }
        let fileData = JSON(fileCompiledData)
        let coins = try await self.restClient.getCoins(account: try self.currentWallet.accounts[0].address())
        if !coins.data.isEmpty {
            var tx = try TransactionBlock()
            let publish = try tx.publish(
                modules: fileData["modules"].arrayObject as! [String],
                dependencies: fileData["dependencies"].arrayObject as! [String]
            )
            let _ = try tx.transferObject(objects: [publish], address: try self.currentWallet.accounts[0].address())
            let options = SuiTransactionBlockResponseOptions(showEffects: true, showObjectChanges: true)
            var result = try await self.restClient.signAndExecuteTransactionBlock(
                transactionBlock: &tx,
                signer: self.currentWallet.accounts[0],
                options: options
            )
            result = try await self.restClient.waitForTransaction(tx: result.digest, options: options)
            guard let objectsChanged = result.objectChanges else { return }
            let packageId = objectsChanged.compactMap {
                switch $0 {
                case .published(let published):
                    return published
                default:
                    return nil
                }
            }[0].packageId.replacingOccurrences(of: "^(0x)(0+)", with: "0x", options: .regularExpression)
            self.collectionId = packageId
        }
    }

    public func createTransaction(_ receiverAddress: AccountAddress, _ amount: Double) async throws -> String? {
        let coins = try await self.restClient.getCoins(account: try self.currentWallet.accounts[0].address())
        if !coins.data.isEmpty {
            var txBlock = try TransactionBlock()
            let coin = try txBlock.splitCoin(
                coin: txBlock.gas,
                amounts: [
                    txBlock.pure(
                        value: .number(
                            UInt64(amount * 1_000_000_000)
                        )
                    )
                ]
            )
            let _ = try txBlock.transferObject(objects: [coin], address: receiverAddress.hex())
            let options = SuiTransactionBlockResponseOptions(showEffects: true)
            var result = try await self.restClient.signAndExecuteTransactionBlock(
                transactionBlock: &txBlock,
                signer: self.currentWallet.accounts[0],
                options: options
            )
            result = try await self.restClient.waitForTransaction(tx: result.digest, options: options)
            return result.digest
        }
        return nil
    }

    private func initializeWallet(_ mnemo: Mnemonic) throws {
        let userDefaults = UserDefaults.standard
        let newWallet = try Wallet(mnemonic: mnemo)
        userDefaults.set(
            mnemo.mnemonic(),
            forKey: try newWallet.accounts[0].address()
        )
        self.wallets.append(newWallet)
        self.currentWallet = newWallet
        self.walletAddress = try self.currentWallet.accounts[0].address()
    }
}
