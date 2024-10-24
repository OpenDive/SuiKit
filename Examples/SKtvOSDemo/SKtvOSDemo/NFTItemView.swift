//
//  NFTItemView.swift
//  SKtvOSDemo
//
//  Created by Marcus Arnett on 10/15/24.
//

import SwiftUI
import SuiKit

struct NFTItemView: View {
    let nft: NFT
    
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
    
    private var asyncImage: some View  {
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
