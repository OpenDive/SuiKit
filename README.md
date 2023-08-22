![SuiKit](./Resources/SuiKitBanner.png)

[![Swift](https://img.shields.io/badge/Swift-5.5_5.6_5.7-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5_5.6_5.7-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-green?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

SuiKit is a Swift SDK natively designed to make developing for the Sui Blockchain easy.

- [Features](#features)
- [ToDo](#todo)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
    - [SPM Through Xcode Project](#spm-through-xcode-project)
    - [SPM Through Xcode Package](#spm-through-xcode-package)
- [Using SuiKit](#using-suikit)
- [Development and Testing](#development-and-testing)
- [Next Steps](#next-steps)
- [Credits](#credits)
- [License](#license)

## Features

- [x] Submitting transactions
- [x] Transferring objects
- [x] Transfer Sui
- [x] Air drop Sui tokens
- [x] Merge and Split coins
- [x] Publish modules
- [x] Transfer objects
- [x] Execute move calls
- [x] Retrieving objects, transactions, checkpoints, coins, and events
- [x] Executing transactions
- [x] Local, custom, dev, test, and main net compatiblity
- [x] ED25519 and SECP256K1 Key and HD Wallet generation
- [x] Native Swift BCS Implementation
- [x] Swift Concurrency Support back to iOS 13, macOS 10.15, tvOS 13, and watchOS 6.
- [x] Comprehensive Unit and Integration Test coverage.

## ToDo

- [ ] Complete documentation of SuiKit.
- [ ] Implement Resolve Name Service Names.
- [ ] Implement SECP256R1 Enclaves.

## Requirements

| Platform | Minimum Swift Version | Installation | Status |
| --- | --- | --- | --- |
| iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ | 5.5 | [Swift Package Manager](#swift-package-manager) | Fully Tested |

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) allows for developers to easily integrate packages into their Xcode projects and packages; and is also fully integrated into the `swift` compiler.

#### SPM Through XCode Project

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/opendive/SuiKit.git`
* Select "Up to next Major" with "1.0"

#### SPM Through Xcode Package

Once you have your Swift package set up, add the Git link within the `dependencies` value of your `Package.swift` file.

```swift
dependencies: [
    .package(url: "https://github.com/opendive/SuiKit.git", .upToNextMajor(from: "1.0"))
]
```

## Using SuiKit

SuiKit is really easy to implement and use in your own projects. Simply provide the provider, transaction block, and signer. Here's an example on how to transfer Sui tokens, which also utilizes the key generation functionality of the library

```swift
import SuiKit
import Bip39

do {
    // Create new wallet
    let newWallet = try Wallet()

    // Create Signer and Provider
    let provider = SuiProvider()
    let signer = RawSigner(account: newWallet.accounts[0], provider: provider)

    // Create transaction block
    var tx = try TransactionBlock()

    // Split coin and prepare transaction
    let coin = try tx.splitCoin(tx.gas, [try tx.pure(value: .number(1_000))])
    try tx.transferObjects([coin], try newWallet.accounts[0].address())

    // Execute transaction
    var result = try await signer.signAndExecuteTransaction(transactionBlock: &tx)
    result = try await provider.waitForTransaction(tx: result.digest)
    print(result)
} catch {
    print("Error: \(error)")
}
```

You can also read objects from the Sui blockchain. Below is an example on how to do so.

```swift
import SuiKit

do {
    // Create provider
    let provider = SuiProvier()

    // Get objects
    let txn = try await provider.getObjects(id: "0xcc2bd176a478baea9a0de7a24cd927661cc6e860d5bacecb9a138ef20dbab231")
} catch {
    print("Error: \(error)")
}
```

As well here is how to use the move call function

```swift
import Suikit
do {
    // Create new wallet
    let newWallet = try Wallet()

    // Create Signer and Provider
    let provider = SuiProvider()
    let signer = RawSigner(account: newWallet.accounts[0], provider: provider)

    // Create transaction block
    var tx = try TransactionBlock()

    // Prepare merge coin 
    try tx.moveCall(
        target: "OxB0B::nft::mint",
        arguments: [.input(try tx.pure(value: .string("Example NFT")))]
    )

    // Execute transaction
    var result = try await signer.signAndExecuteTransaction(transactionBlock: &tx)
    result = try await provider.waitForTransaction(tx: result.digest)
    print (result)
catch {
    print ("Error: (error)")
}
```

And this is how to publish a package. (Note: it is recommended for this to be used in a CLI / MacOS enviornment)

```swift
import SuiKit 
import SwiftyJSON

do {
    // Import Package Module JSON
    guard let fileUrl = Bundle. main.ur(forResource: "Package", withExtension: "json") else {
        throw NSError (domain: "Package is missing", code: -1)
    }
    guard let fileCompiledData = try? Data(contentsOf: fileUrl) else {
        throw NSError (domain: "Package is corrupted", code: -1)
    }
    let fileData = JSON (fileCompiledData)

    // Create new wallet
    let newWallet = try Wallet()

    // Create Signer and Provider
    let provider = SuiProvider()
    let signer = RawSigner(account: newWallet.accounts[0], provider: provider)

    // Create transaction block
    var tx = try TransactionBlock()

    // Prepare Publish
    let publishObject = try tx.publish(
        modules: fileData["modules"], 
        dependencies: fileData["dependencies"]
    )

    // Prepare Transfer Object
    try t×.transferObjects([publishObject], try newWallet.accounts[0].address())

    // Execute transaction
    var result = try await signer.signAndExecuteTransaction(transactionBlock: &tx)
    result = try await provider.waitForTransaction(tx: result.digest)
    print(result)
} catch {
    print("Error: \(error)")
}
```

## Development And Testing

We welcome anyone to contribute to the project through posting issues, if they encounter any bugs / glitches while using SuiKit; and as well with creating pull issues that add any additional features to SuiKit.

## Next Steps

* In the near future, there will be full documentation outlining how a user can fully utilize SuiKit.
* As well, more features listed in [ToDo](#todo) will be fully implemented.
* More examples, from other platforms, will be uploaded for developers to be able to focus more on implementing the end user experience, and less time figuring out their project's architecture.

## Credits

Credit goes to [The Sui Foundation](https://sui.io) for providing the needed infrastructure for the Sui blockchain network, as well with their extensive RPC documentation.

## License

SuiKit is released under the MIT license.
