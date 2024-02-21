//
//  CreateCollectionView.swift
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

struct CreateCollectionView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isCreatingCollection: Bool = false

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

            if isCreatingCollection {
                Text("Creating Collection...")
                    .font(.title)
                    .padding(.top)
            } else {
                Text("Create a Collection")
                    .font(.title)
                    .padding(.top)
            }

            Button {
                Task {
                    do {
                        self.isCreatingCollection = true
                        try await self.viewModel.createCollection()
                        self.message = "Successfully uploaded contract!"
                        self.isShowingPopup = true
                    } catch {
                        self.message = "Something went wrong: \(error)"
                        self.isShowingPopup = true
                    }
                }
            } label: {
                if isCreatingCollection {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Create Collection")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
            .padding(.top)

            Button {
                let objectId = self.viewModel.fetchObjectId()
                UIPasteboard.general.setValue(
                    objectId,
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Text("Copy Object ID")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)

            }

            Spacer()
        }
        .alert("\(message)", isPresented: $isShowingPopup) {
            Button("OK", role: .cancel) {
                self.isShowingPopup = false
                self.message = ""
                self.isCreatingCollection = false
            }
        }
    }
}

struct CreateCollectionView_Previews: PreviewProvider {
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
            CreateCollectionView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        WrapperView()
    }
}
