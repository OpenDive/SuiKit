//
//  NFT.swift
//  SKtvOSDemo
//
//  Created by Marcus Arnett on 10/15/24.
//

import Foundation

struct NFTItem: Identifiable {
    let id = UUID()

    let name: String
    let imageUrl: URL?
    let description: String
    let stats: [String: String]?
    let collectionName: String
}
