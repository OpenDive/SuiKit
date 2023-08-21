//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/21/23.
//

import Foundation

/// An enum representing the available authorization key schemes for Aptos Blockchain accounts.
enum AuthKeyScheme {
    /// The ED25519 authorization key scheme value.
    static let ed25519: UInt8 = 0x00

    /// The multi-ED25519 authorization key scheme value.
    static let multiEd25519: UInt8 = 0x01

    /// The authorization key scheme value used to derive an object address from a GUID.
    static let deriveObjectAddressFromGuid: Data = Data([0xFD])

    /// The authorization key scheme value used to derive an object address from a seed.
    static let deriveObjectAddressFromSeed: UInt8 = 0xFE

    /// The authorization key scheme value used to derive a resource account address.
    static let deriveResourceAccountAddress: UInt8 = 0xFF
}
