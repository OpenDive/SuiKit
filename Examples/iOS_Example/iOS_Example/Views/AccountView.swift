//
//  AccountView.swift
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
import UniformTypeIdentifiers

struct AccountView: View {
    @ObservedObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    @State private var isAirdropping: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var isShowingError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Image("suiLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 200)
                .padding(.horizontal)
                .padding(.top, 25)

            if isAirdropping {
                Text("Airdropping 10 SUI...")
                    .font(.title)
                    .padding(.top)
            } else {
                Text("Account Settings")
                    .font(.title)
                    .padding(.top)
            }

            Button {
                UIPasteboard.general.setValue(
                    self.viewModel.currentWallet.mnemonic.mnemonic().joined(separator: " "),
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Text("Copy Mnemonic Words")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)

            Button {
                UIPasteboard.general.setValue(
                    self.viewModel.walletAddress,
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Text("Copy Address")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)

            Button {
                Task {
                    do {
                        self.isAirdropping = true
                        try await self.viewModel.airdropToCurrentWallet()
                        self.isShowingAlert = true
                    } catch let error as SuiError {
                        self.isAirdropping = false
                        self.errorMessage = "\(error)"
                        self.isShowingError = true
                    }
                }
            } label: {
                if isAirdropping {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Airdrop 10 SUI")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
            .padding(.top)

            Spacer()
        }
        .alert("Successfully Airdropped 10 SUI", isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) {
                self.isAirdropping = false
                self.isShowingAlert = false
            }
        }
        .alert("There was an error airdropping: \(self.errorMessage)", isPresented: $isShowingError) {
            Button("OK", role: .cancel) {
                self.isShowingError = false
                self.errorMessage = ""
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
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
            AccountView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        WrapperView()
    }
}
