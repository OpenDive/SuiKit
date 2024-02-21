//
//  MintNFTView.swift
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

struct MintNFTView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var objectId: String = "0xf0048471654fd5cad2e9c0db7243fc5094693153802bec6dcf49e255ec29a6a1"
    @State private var tokenName: String = "SuiTestingCollectionNFT"
    @State private var tokenDescription: String = "SuiTestingCollection"
    @State private var supply: String = "100"
    @State private var tokenURL: String = "https://assets-global.website-files.com/6425f546844727ce5fb9e5ab/6439ab96e20cad137a4c80d0_TopNavLogo.svg"

    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isMintingNft: Bool = false

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

            if isMintingNft {
                Text("Creating NFT...")
                    .font(.title)
                    .padding(.top)
            } else {
                Text("Create an NFT")
                    .font(.title)
                    .padding(.top)
            }

            VStack {
                TextField("Object ID", text: $objectId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)

                TextField("Name", text: $tokenName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)

                TextField("Description", text: $tokenDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)

                TextField("Supply (Int)", text: $supply)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)

                TextField("URL", text: $tokenURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
            }

            Button {
                Task {
                    do {
                        self.isMintingNft = true
                        let digest = try await self.viewModel.createNft(
                            tokenName,
                            objectId,
                            tokenDescription,
                            tokenURL
                        )
                        self.message = "Successfully minted your NFT at digest: \(digest!)"
                        self.isShowingPopup = true
                    } catch {
                        self.message = "Something went wrong: \(error.localizedDescription)"
                        self.isShowingPopup = true
                    }
                }
            } label: {
                if isMintingNft {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Create NFT")
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
                self.isMintingNft = false
            }
        }
    }
}

struct MintNFTView_Previews: PreviewProvider {
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
            MintNFTView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        WrapperView()
    }
}
