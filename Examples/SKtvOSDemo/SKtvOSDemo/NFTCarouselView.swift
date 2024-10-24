//
//  NFTCarouselView.swift
//  SKtvOSDemo
//
//  Created by Marcus Arnett on 10/15/24.
//

import SwiftUI

struct NFTCarouselView: View {
    let collectionName: String
    let nfts: [NFT]
    
    var body: some View {
        Text(self.collectionName)
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 64)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 32) {
                ForEach(self.nfts) { nft in
                    NavigationLink {
//                        ArticleDetailView(article: article)
                    } label: {
                        NFTItemView(nft: nft)
                            .frame(width: 420, height: 420)
                    }
                    .buttonStyle(.card)
                }
            }
            .padding([.bottom, .horizontal], 64)
            .padding(.top, 32)
        }
    }
}
