// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SuiKit",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13), .custom("xros", versionString: "1.0")],
    products: [
        .library(
            name: "SuiKit",
            targets: ["SuiKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hyugit/UInt256.git", from: "0.2.2"),
        .package(url: "https://github.com/pebble8888/ed25519swift.git", from: "1.2.7"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/tesseract-one/Blake2.swift.git", exact: "0.1.2"),
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
        .package(url: "https://github.com/keefertaylor/Base58Swift.git", from: "2.1.0"),
        .package(url: "https://github.com/tesseract-one/Bip39.swift.git", from: "0.1.1"),
        .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.2.0")
    ],
    targets: [
        .target(
            name: "SuiKit",
            dependencies: [
                .product(name: "UInt256", package: "UInt256"),
                .product(name: "ed25519swift", package: "ed25519swift"),
                .product(name: "SwiftyJSON", package: "swiftyjson"),
                .product(name: "Blake2", package: "Blake2.swift"),
                .product(name: "AnyCodable", package: "AnyCodable"),
                .product(name: "Base58Swift", package: "Base58Swift"),
                .product(name: "Bip39", package: "Bip39.swift"),
                .product(name: "web3swift", package: "web3swift")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SuiKitTests",
            dependencies: ["SuiKit"],
            path: "Tests",
            resources: [.copy("Resources")]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
