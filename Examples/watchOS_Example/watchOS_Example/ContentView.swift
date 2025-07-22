//
//  ContentView.swift
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

import SwiftUI
import SuiKit
import UniformTypeIdentifiers
import Foundation
import Bip39
import SwiftyJSON
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var currentWalletBalance: Double = 0.0
    @State private var phrase: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isGettingBalance: Bool = false

    @FocusState private var isFocused: Bool

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    func setupWCSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = WCSessionDelegateHandler.shared
            WCSession.default.activate()
        }
    }

    func sendMessageToWatch(addresses: [String]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["addresses": addresses], replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        }
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
                    self.sendMessageToWatch(addresses: try self.viewModel.getWalletAddresses())
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
        .onAppear {
            setupWCSession()

            if !self.viewModel.wallets.isEmpty {
                self.sendMessageToWatch(addresses: try! self.viewModel.getWalletAddresses())
            }
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
        .onChange(of: self.viewModel.currentWallet) { _, _ in
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

class WCSessionDelegateHandler: NSObject, WCSessionDelegate {
    static let shared = WCSessionDelegateHandler()

    private override init() { super.init() }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let receivedMessage = message["addresses"] as? [String] {
            DispatchQueue.main.async {
                // Handle received message here (e.g., update the UI)
                NotificationCenter.default.post(name: NSNotification.Name("receivedMessage"), object: receivedMessage)
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
            ContentView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        WrapperView()
    }
}

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
            var lastWallet: Wallet?
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
        _ = try await self.faucetClient.funcAccount(try self.currentWallet.accounts[0].address())
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
