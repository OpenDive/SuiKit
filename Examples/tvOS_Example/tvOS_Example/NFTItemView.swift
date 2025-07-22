//
//  NFTItemView.swift
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

struct NFTItemView: View {
    let nft: NFTItem

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 24) {
                asyncImage
                    .frame(height: proxy.size.height * 0.6)
                    .backgroundStyle(Color.gray.opacity(0.6))
                    .clipped()

                VStack(alignment: .leading) {
                    Text(nft.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(3)

                    Spacer(minLength: 12)
                }
                .padding([.horizontal, .bottom])
            }
        }
    }

    private var asyncImage: some View {
        AsyncImage(url: nft.imageUrl) { phase in
            switch phase {
            case .empty:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            case .failure:
                HStack {
                    Spacer()
                    Image(systemName: "photo")
                        .imageScale(.large)
                    Spacer()
                }

            @unknown default:
                fatalError()
            }
        }
    }
}
