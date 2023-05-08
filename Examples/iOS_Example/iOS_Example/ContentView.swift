//
//  ContentView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 5/1/23.
//

import SwiftUI
import SuiKit

struct ContentView: View {
    @State var viewModel: HomeViewModel

    init() {
        do {
            let userDefaults = UserDefaults.standard
            var defaultWalletSeeds: [[String]] = []
            
            for element in userDefaults.dictionaryRepresentation() {
                let mnemo = userDefaults.object(forKey: element.key) as? [String]
                
                if let mnemo, mnemo.count == 12 {
                    defaultWalletSeeds.append(mnemo)
                }
            }
            
            if defaultWalletSeeds.isEmpty {
                self.viewModel = try HomeViewModel()
                userDefaults.set(
                    self.viewModel.currentWallet.mnemonic.phrase,
                    forKey: self.viewModel.currentWallet.account.accountAddress.description
                )
            } else {
                self.viewModel = try HomeViewModel(defaultWalletSeeds)
            }
        } catch {
            print(error)
            fatalError()
        }
    }
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Accounts", systemImage: "person.fill.badge.plus")
                }

            AccountView(viewModel: viewModel)
                .tabItem {
                    Label("Account Settings", systemImage: "person")
                }

            MintNFTView(viewModel: viewModel)
                .tabItem {
                    Label("NFT", systemImage: "photo.artframe")
                }

            CreateCollectionView(viewModel: viewModel)
                .tabItem {
                    Label("Collection", systemImage: "shippingbox.fill")
                }

            TransferView(viewModel: viewModel)
                .tabItem {
                    Label("Transaction", systemImage: "bitcoinsign.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
