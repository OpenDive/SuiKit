//
//  NFTCollectionsViewModel.swift
//  SKtvOSDemo
//
//  Created by Marcus Arnett on 10/15/24.
//

import SwiftUI
import SuiKit

@MainActor
class NFTCollectionsViewModel: ObservableObject {
    @Published var phase = DataFetchPhase<[NFTCollection]>.empty

    private let nftApi = NFTApi.shared

    var collections: [NFTCollection] {
        self.phase.value ?? []
    }
}

enum DataFetchPhase<T> {
    case empty
    case success(T)
    case failure(Error)

    var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
}

struct NFTCollection {
    let collectionName: String
    let nfts: [NFT]
}

struct NFTApi {
    static let shared = NFTApi()

    // TODO: Replace with way of getting input wallet through zkLogin
    let walletAddress = "0x11e1167ee826093a81b40da90cc12cd12f47e16939454e245865cd5822d1a0c3"

    private init() { }

    func fetchCollections() async throws -> [NFTCollection] {
        try await withThrowingTaskGroup(of: Swift.Result<NFT, Error>.self) { group in
            let provider = SuiProvider(connection: MainnetConnection())
            let kiosk = KioskClient(client: provider, network: .mainnet)

            let kioskCollections = try await kiosk.getOwnedKiosks(address: walletAddress)

            for object in kioskCollections.kioskOwnerCaps.map(\.objectId) {
                group.addTask {
                    await self.fetchNFT(objectId: object, provider: provider)
                }
            }

            var results = [Swift.Result<NFT, Error>]()

            for try await result in group {
                results.append(result)
            }

            if
                let first = results.first,
                case .failure(let failure) = first {
                throw failure
            }

            var nfts = [NFT]()

            for result in results {
                if case .success(let nft) = result {
                    nfts.append(nft)
                }
            }

            var sortedNFTs: [String: [NFT]] = [:]

            for nft in nfts {
                if sortedNFTs[nft.collectionName] == nil {
                    sortedNFTs[nft.collectionName] = [nft]
                } else {
                    sortedNFTs[nft.collectionName]!.append(nft)
                }
            }

            var collections: [NFTCollection] = []

            for category in sortedNFTs.keys.sorted() {
                collections.append(NFTCollection(collectionName: category, nfts: sortedNFTs[category]!))
            }

            return collections
        }
    }

    func fetchNFTCollectionName(type: String, provider: SuiProvider) async throws -> String {
        let url = URL(string: "https://api.blockberry.one/sui/v1/collections/\(type)")!
        let apiKey = "XTWKsL0UXo8PximtNKy1SsjXvPbO23"  // TODO: Remove this before putting into PROD
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "*/*", "x-api-key": apiKey]

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(CollectionDecoder.self, from: data).collectionName
    }

    func fetchNFT(objectId: String, provider: SuiProvider) async -> Swift.Result<NFT, Error> {
        do {
            guard let nft = try await provider.getObject(
                objectId: ObjectId,
                options: SuiObjectDataOptions(showDisplay: true)
            ) else {
                throw NSError(domain: "Unable to fetch NFT", code: 2)
            }

            guard let displayData = nft.data?.display?.data else {
                throw NSError(domain: "Unable to parse display data", code: 1)
            }

            let collectionName = try await self.fetchNFTCollectionName(type: nft.data!.type!, provider: provider)

            print("DEBUG::: DISPLAY DATA - \(displayData)")

            return .success(
                NFT(
                    name: displayData["name"] ?? "Unknown",
                    imageUrl: URL(string: displayData["url"] ?? "https://google.com")!,
                    description: displayData["description"] ?? "No description available",
                    stats: nil,  // TODO: Implement method for fetching description
                    collectionName: collectionName
                )
            )
        } catch {
            return .failure(error)
        }
    }
}

// {
//  "collectionType": "0xcc2650b0d0b949e9cf4da71c22377fcbb78d71ce9cf0fed3e724ed3e2dc57813::boredapesuiclub_collection::BoredApeSuiClub",
//  "collectionName": "Bored Ape Sui Club",
//  "collectionImg": "https://ipfs.io/ipfs/bafybeicnuu37rwdmxcn3oobmbvgtji6kn52xtrkysgjn4nrxcnhchfsu4q/assets/235.png",
//  "description": "Bored Ape Sui Club is a whole new existence of 5000 unique Bored Apes with new traits compositions living in the Sui Ecosystem. Not affiliated with Yuga Labs.",
//  "securityMessage": null,
//  "projectSecurityMessage": null,
//  "packageId": "0xcc2650b0d0b949e9cf4da71c22377fcbb78d71ce9cf0fed3e724ed3e2dc57813",
//  "packageName": "Bored Ape Sui Club NFT",
//  "projectName": null,
//  "projectImg": null,
//  "creatorAddress": "0x6b47af23232ef8fa0c5a3c7d73b74253f6545e94a26eef0e05840c4b69e13667",
//  "creatorName": null,
//  "creatorImg": null,
//  "creatorSecurityMessage": null,
//  "socialWebsite": "https://twitter.com/BoredApeSuiClub",
//  "nftsCount": 4994,
//  "latestPrice": 1.111,
//  "volume": 0,
//  "holdersCount": 1173,
//  "marketplaces": [
//    "TradePort",
//    "Souffl3",
//    "Hyperspace",
//    "Tocen",
//    "BlueMove"
//  ],
//  "createTimestamp": 1683560584345
// }
struct CollectionDecoder: Codable {
    let collectionName: String
}
