//
//  TransferView.swift
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

struct TransferView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var receiverAddress: String = ""
    @State private var tokenAmount: String = "0.2"

    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isTransfering: Bool = false

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

            if isTransfering {
                Text("Sending Transaction...")
                    .font(.title)
                    .padding(.top)
            } else {
                Text("Send Transaction")
                    .font(.title)
                    .padding(.top)
            }

            VStack {
                ZStack {
                    Text("Sender Address: ") +
                    Text("\(self.viewModel.walletAddress)").bold()
                }
                .padding()

                TextField("Receiver Address", text: $receiverAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    .focused($isFocused)

                TextField("Token Amount (SUI)", text: $tokenAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                    .focused($isFocused)
            }

            Button {
                self.isFocused = false
                Task {
                    do {
                        self.isTransfering = true
                        guard let amountDouble = Double(tokenAmount) else {
                            self.message = "Please use a valid Double for royalty points and / or supply number."
                            self.isShowingPopup = true
                            return
                        }
                        guard !receiverAddress.isEmpty else {
                            self.message = "Please provide a valid receiver Address"
                            self.isShowingPopup = true
                            return
                        }
                        let digest = try await self.viewModel.createTransaction(AccountAddress.fromHex(self.receiverAddress), amountDouble)
                        self.message = "Successfully Executed Transaction at digest: \(digest!)"
                        self.isShowingPopup = true
                    } catch {
                        self.message = "Something went wrong: \(error)"
                        self.isShowingPopup = true
                    }
                }
            } label: {
                if isTransfering {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Create Transaction")
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
        .alert("\(message)", isPresented: $isShowingPopup) {
            Button("OK", role: .cancel) {
                self.isShowingPopup = false
                self.message = ""
                self.isTransfering = false
            }
        }
    }
}

struct TransferView_Previews: PreviewProvider {
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
            TransferView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        WrapperView()
    }
}
