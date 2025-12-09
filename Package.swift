// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SuiKit",
    platforms: [.iOS(.v17), .macOS(.v13), .watchOS(.v9), .tvOS(.v17)],
    products: [
        .library(
            name: "SuiKit",
            targets: ["SuiKit"]),
        .library(
            name: "GraphqlSchemaSuiKit",
            targets: ["GraphqlSchemaSuiKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0"),
        .package(url: "https://github.com/pebble8888/ed25519swift.git", from: "1.2.7"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/tesseract-one/Blake2.swift.git", from: "0.2.0"),
        .package(url: "https://github.com/auth0/JWTDecode.swift", from: "3.1.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "2.0.3"),
        .package(url: "https://github.com/tesseract-one/UncommonCrypto.swift.git", .upToNextMinor(from: "0.2.0"))
    ],
    targets: [
        .target(
            name: "secp256k1sui"
        ),
        .target(
            name: "GraphqlSchemaSuiKit",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ]
        ),
        .target(
            name: "SuiKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "UInt256", package: "UInt256"),
                .product(name: "ed25519swift", package: "ed25519swift"),
                .product(name: "SwiftyJSON", package: "swiftyjson"),
                .product(name: "Blake2", package: "Blake2.swift"),
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "UncommonCrypto", package: "UncommonCrypto.swift"),
                "secp256k1sui",
                "GraphqlSchemaSuiKit"
            ]
        ),
        .testTarget(
            name: "SuiKitTests",
            dependencies: ["SuiKit"],
            path: "Tests",
            resources: [
                .copy("Resources/*.json")
            ]
        ),
    ]
)
