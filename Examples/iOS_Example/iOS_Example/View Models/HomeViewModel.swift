//
//  HomeViewModel.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 5/5/23.
//

import Foundation
import SuiKit

public class HomeViewModel: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var currentWallet: Wallet

    let restBaseUrl = "https://sui-devnet-kr-1.cosmostation.io"
    let faucetUrl = "https://faucet.devnet.sui.io/gas"

    public init(_ mnemos: [[String]]? = nil) throws {
        if let mnemos {
            var tmpWallets: [Wallet] = []
            var lastWallet: Wallet? = nil
            for mnemo in mnemos {
                let mnemoObject = try Mnemonic(phrase: mnemo)
                let newWallet = try Wallet(mnemonic: mnemoObject)
                tmpWallets.append(newWallet)
                lastWallet = newWallet
            }
            self.wallets = tmpWallets
            self.currentWallet = lastWallet!
        } else {
            let mnemo = Mnemonic(wordcount: 12, wordlist: Wordlists.english)
            let newWallet = try Wallet(mnemonic: mnemo)
            self.currentWallet = newWallet
            self.wallets = [newWallet]
        }
    }

    public init(wallet: Wallet) {
        self.currentWallet = wallet
        self.wallets = [wallet]
    }

    public func createWallet() throws {
        let mnemo = Mnemonic(wordcount: 12, wordlist: Wordlists.english)
        try self.initializeWallet(mnemo)
    }

    public func restoreWallet(_ phrase: String) throws {
        let mnemo = try Mnemonic(phrase: phrase.components(separatedBy: " "))
        try self.initializeWallet(mnemo)
    }

    public func getWalletAddresses() -> [String] {
        return wallets.map { $0.account.address().hex() }
    }

    public func getCurrentWalletAddress() -> String {
        return self.currentWallet.account.address().description
    }

    public func getCurrentWalletBalance() async throws -> Double {
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: self.restBaseUrl))
        return Double(
            try await restClient.getBalance(self.currentWallet.account.accountAddress, "").totalBalance
        ) ?? 0 / Double(100_000_000)
    }

    public func airdropToCurrentWallet() async throws {
        let faucetClient = FaucetClient(baseUrl: faucetUrl)

        let _ = try await faucetClient.funcAccount(self.currentWallet.account.accountAddress.description)
    }

    public func createNft(
        _ signer: Account,
        _ name: String,
        _ objectId: String,
        _ description: String,
        _ url: String,
        _ mintCap: String,
        _ recipient: String
    ) async throws {
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: self.restBaseUrl))
        let objects = try await restClient.getOwnedObjects(signer.accountAddress)
        let suiCoinObjects = objects.filter { $0.type == "0x2::coin::Coin<0x2::sui::SUI>" }
        
        if !suiCoinObjects.isEmpty {
            let txArguments: [String] = [
                name,
                description,
                url,
                mintCap,
                recipient
            ]
            let gas = try await restClient.getGasPrice()
            let tx = try await restClient.moveCall(
                signer,
                objectId,
                "moduleName",
                name,
                [],
                txArguments,
                suiCoinObjects[0].objectId,
                "\(Int(1_000 * gas + 1_000_000))",
                .waitforEffectsCert
            )
            let _ = try await restClient.executeTransactionBlocks(tx, signer)
        }
    }
    
    public func fetchObjectId() async throws -> String {
        var returnId: String = ""
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: self.restBaseUrl))
        let objects = try await restClient.getOwnedObjects(self.currentWallet.account.accountAddress)
        print(objects)
        return returnId
    }

    public func createCollection(_ signer: Account) async throws {
        guard let fileUrl = Bundle.main.url(forResource: "collection", withExtension: "move") else {
            throw NSError(domain: "Collection is missing", code: -1)
        }
        let fileData = try Data(contentsOf: fileUrl)
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: self.restBaseUrl))
        let objects = try await restClient.getOwnedObjects(signer.accountAddress)
        let suiCoinObjects = objects.filter { $0.type == "0x2::coin::Coin<0x2::sui::SUI>" }
        
        if !suiCoinObjects.isEmpty {
            let gas = try await restClient.getGasPrice()
            let tx = try await restClient.publish(
                signer,
                [fileData.base64EncodedString()],
                [],
                suiCoinObjects[0].objectId,
                "\(Int(1_000 * gas + 1_000_000))"
            )
            let _ = try await restClient.executeTransactionBlocks(tx, signer)
        }
    }

    public func createTransaction(_ signer: Account, _ receiverAddress: AccountAddress, _ amount: Double) async throws {
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: self.restBaseUrl))
        let objects = try await restClient.getOwnedObjects(signer.accountAddress)
        let suiCoinObjects = objects.filter { $0.type == "0x2::coin::Coin<0x2::sui::SUI>" }
        
        if !suiCoinObjects.isEmpty {
            let gas = try await restClient.getGasPrice()
            let tx = try await restClient.transferSui(
                signer,
                receiverAddress,
                "\(Int(1_000 * gas + 1_000_000))",
                "\(Int(amount * 1_000_000_000))",
                suiCoinObjects[0].objectId
            )
            let _ = try await restClient.executeTransactionBlocks(tx, signer)
        }
    }

    private func initializeWallet(_ mnemo: Mnemonic) throws {
        let userDefaults = UserDefaults.standard
        let newWallet = try Wallet(mnemonic: mnemo)
        userDefaults.set(
            mnemo.phrase,
            forKey: newWallet.account.accountAddress.description
        )
        self.wallets.append(newWallet)
        self.currentWallet = newWallet
    }
}
