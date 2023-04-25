// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuiKit",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "SuiKit",
            targets: ["SuiKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hyugit/UInt256.git", from: "0.2.2"),
        .package(url: "https://github.com/pebble8888/ed25519swift.git", from: "1.2.7"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/tesseract-one/Blake2.swift.git", from: "0.1.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "SuiKit",
            dependencies: [
                .product(name: "UInt256", package: "UInt256"),
                .product(name: "ed25519swift", package: "ed25519swift"),
                .product(name: "SwiftyJSON", package: "swiftyjson"),
                .product(name: "Blake2", package: "Blake2.swift"),
                .product(name: "AnyCodable", package: "AnyCodable")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SuiKitTests",
            dependencies: ["SuiKit"],
            path: "Tests",
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
