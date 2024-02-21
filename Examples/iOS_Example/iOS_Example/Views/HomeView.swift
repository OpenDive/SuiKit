//
//  HomeView.swift
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

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var currentWalletBalance: Double = 0.0
    @State private var phrase: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isGettingBalance: Bool = false

    @FocusState private var isFocused: Bool

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Image("suiLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 200)
                .padding(.horizontal)
                .padding(.top, 25)

            if isGettingBalance {
                Text("Loading Balance...")
                    .font(.title)
                    .padding(.top)
            } else {
                Text("Add Account")
                    .font(.title)
                    .padding(.top)
            }

            Button {
                do {
                    try self.viewModel.createWallet()
                } catch {
                    print("ERROR - \(error)")
                }
            } label: {
                Text("Create Wallet")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)

            Button {
                self.isFocused = false
                do {
                    try self.viewModel.restoreWallet(phrase)
                    self.phrase = ""
                } catch {
                    self.phrase = ""
                }
            } label: {
                Text("Import Wallet")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)

            if !self.viewModel.wallets.isEmpty {
                Picker("Select A Wallet", selection: self.$viewModel.currentWallet) {
                    ForEach(self.viewModel.wallets, id: \.self) { wallet in
                        Text("\((try? wallet.accounts[0].address()) ?? "No current address")")
                    }
                }
                .pickerStyle(.menu)
                .padding(.top, 40)
                .padding(.horizontal)
                
                Text("Current Wallet Balance: \(self.currentWalletBalance) SUI")
                    .padding(.top)
            } else {
                Text("Generate or Import a wallet")
                    .padding(.top, 40)
            }

            TextField("Enter your seed phrase", text: $phrase)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top)
                .focused($isFocused)

            Spacer()
        }
        .task {
            Task {
                do {
                    self.isGettingBalance = true
                    self.currentWalletBalance = try await self.viewModel.getCurrentWalletBalance()
                    self.isGettingBalance = false
                } catch {
                    print("ERROR - \(error)")
                }
            }
        }
        .onChange(of: self.viewModel.currentWallet) { newValue in
            Task {
                do {
                    self.isGettingBalance = true
                    self.currentWalletBalance = try await self.viewModel.getCurrentWalletBalance()
                    self.isGettingBalance = false
                    self.viewModel.walletAddress = try self.viewModel.currentWallet.accounts[0].address()
                } catch {
                    print("ERROR - \(error)")
                }
            }
        }
        .alert("Seed Phrase is Invalid, please try again.", isPresented: $isShowingPopup) {
            Button("OK", role: .cancel) {
                self.isShowingPopup = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    struct WrapperView: View {
        @State var viewModel: HomeViewModel

        init() {
            do {
                self.viewModel = try HomeViewModel()
            } catch {
                fatalError()
            }
        }

        var body: some View {
            HomeView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        WrapperView()
    }
}

