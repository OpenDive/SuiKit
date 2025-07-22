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
import WatchConnectivity
import QRCode

struct ContentView: View {
    @State private var wallets: [String] = []

    var body: some View {
        ScrollView {
            VStack {
                Text("Items List")
                    .font(.headline)
                    .padding(.top)

                ForEach(self.wallets, id: \.self) { wallet in
                    NavigationLink(destination: WalletDetailView(wallet: wallet)) {
                        Text(shortenWalletAddress(wallet))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            if WCSession.isSupported() {
                WCSession.default.delegate = WCSessionDelegateHandler.shared
                WCSession.default.activate()
            }
            if let cachedWallets = UserDefaults.standard.array(forKey: "cachedWallets") as? [String] {
                self.wallets = cachedWallets
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("receivedMessage"), object: nil, queue: .main) { notification in
                if let receivedMessage = notification.object as? [String] {
                    self.wallets = receivedMessage
                    UserDefaults.standard.set(receivedMessage, forKey: "cachedWallets")
                }
            }
        }
    }

    private func shortenWalletAddress(_ address: String) -> String {
        guard address.count > 8 else { return address }
        let prefix = address.prefix(5)
        let suffix = address.suffix(3)
        return "\(prefix)...\(suffix)"
    }
}

struct WalletDetailView: View {
    var wallet: String
    @State private var isShowingQRCode = false
    @State private var isLoading = false
    @State private var isAirdropSuccessful = false

    private func shortenWalletAddress(_ address: String) -> String {
        guard address.count > 8 else { return address }
        let prefix = address.prefix(5)
        let suffix = address.suffix(3)
        return "\(prefix)...\(suffix)"
    }

    var body: some View {
        ZStack {
            VStack {
                Text(shortenWalletAddress(wallet))
                    .font(.headline)
                    .padding()

                Spacer()

                Button(action: {
                    isLoading = true
                    Task {
                        do {
                            let faucet = FaucetClient(connection: LocalnetConnection())
                            _ = try await faucet.funcAccount(wallet)
                            isLoading = false
                            isAirdropSuccessful = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isAirdropSuccessful = false
                            }
                        } catch {
                            isLoading = false
                            print("Airdrop failed: \(error)")
                        }
                    }
                }) {
                    Text("Airdrop 10 SUI")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Button(action: {
                    // Get QR code action
                    isShowingQRCode = true
                }) {
                    Text("Get QR code")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .padding()
            .sheet(isPresented: $isShowingQRCode) {
                QRCodeView(wallet: wallet)
            }

            if isLoading {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    ProgressView()
                        .scaleEffect(3)

                    Text("Airdropping 10 SUI...")
                        .padding(.top)
                }
            }

            if isAirdropSuccessful {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    Text("Airdrop to \(shortenWalletAddress(wallet))")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.top)
                    Text("successful!")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                }
            }
        }
    }
}

struct QRCodeView: View {
    var wallet: String

    var body: some View {
        VStack {
            if let qrImage = generateQRCode(from: wallet) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            } else {
                Text("Failed to generate QR code")
                    .foregroundColor(.red)
            }
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        do {
            let doc = try QRCode.Document(utf8String: string)
            let cgImage = try doc.cgImage(dimension: 400)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating QR code: \(error)")
            return nil
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

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let receivedMessage = message["addresses"] as? [String] {
            DispatchQueue.main.async {
                // Handle received message here (e.g., update the UI)
                NotificationCenter.default.post(name: NSNotification.Name("receivedMessage"), object: receivedMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}
