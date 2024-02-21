//
//  ContentView.swift
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
                    self.viewModel.currentWallet.mnemonic.mnemonic(),
                    forKey: try self.viewModel.currentWallet.accounts[0].address()
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
