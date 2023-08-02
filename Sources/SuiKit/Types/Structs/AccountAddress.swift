//
//  AccountAddress.swift
//  SuiKit
//
//  Copyright (c) 2023 OpenDive
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

import Foundation
import CryptoSwift
import Blake2

/// An enum representing the available authorization key schemes for sui Blockchain accounts.
enum AuthKeyScheme {
    /// The ED25519 authorization key scheme value.
    static let ed25519: UInt8 = 0x00

    /// The multi-ED25519 authorization key scheme value.
    static let multiEd25519: UInt8 = 0x01
}

/// The sui Blockchain Account Address
public struct AccountAddress: KeyProtocol, Equatable, CustomStringConvertible {
    /// The address data itself
    public let address: Data

    /// The length of the data in bytes
    static let length: Int = 32

    public init(address: Data) throws {
        self.address = address

        if address.count != AccountAddress.length {
            throw SuiError.invalidAddressLength
        }
    }

    public var description: String {
        return self.hex()
    }

    public func base64() -> String {
        return address.base64EncodedString()
    }

    /// Gives the hex value of the address
    /// - Returns: A String value represnting the address's hex value
    public func hex() -> String {
        return "0x\(address.hexEncodedString())"
    }

    public func toSuiAddress() throws -> String {
        var tmp = Data(count: AccountAddress.length + 1)
        try tmp.set([Signature.SIGNATURE_SCHEME_TO_FLAG["ED25519"]!])
        try tmp.set([UInt8](self.address), offset: 1)
        let result = normalizeSuiAddress(
            value: try Blake2.hash(.b2b, size: 32, data: tmp).hexEncodedString()[0..<AccountAddress.length * 2]
        )
        return result
    }

    /// Create an AccountAddress instance from a hexadecimal string.
    ///
    /// This function creates an AccountAddress instance from a hexadecimal string representing the account address. If the provided hexadecimal string starts with "0x",
    /// the function removes it before attempting to create the AccountAddress instance. If the length of the hexadecimal string is less than AccountAddress.length times 2,
    /// the function pads it with leading zeros to reach the required length.
    ///
    /// - Parameters:
    ///    - address: A string representing the hexadecimal account address to create the AccountAddress instance from.
    ///
    /// - Returns: An AccountAddress instance created from the provided hexadecimal string.
    ///
    /// - Throws: An error of type SuiError indicating that the provided hexadecimal string is invalid and cannot be converted to an AccountAddress instance.
    public static func fromHex(_ address: String) throws -> AccountAddress {
        var addr = address

        if address.hasPrefix("0x") {
            addr = String(address.dropFirst(2))
        }

        if addr.count < AccountAddress.length * 2 {
            let pad = String(repeating: "0", count: AccountAddress.length * 2 - addr.count)
            addr = pad + addr
        }

        return try AccountAddress(address: Data(hex: addr))
    }

    /// Create an AccountAddress instance from a PublicKey.
    ///
    /// This function creates an AccountAddress instance from a provided PublicKey. The function generates a new address by appending the ED25519 authorization key
    /// scheme value to the byte representation of the provided public key, and then computes the SHA3-256 hash of the resulting byte array. The resulting hash is used to
    /// create a new AccountAddress instance.
    ///
    /// - Parameters:
    ///    - key: A PublicKey instance representing the public key to create the AccountAddress instance from.
    ///
    /// - Returns: An AccountAddress instance created from the provided PublicKey.
    ///
    /// - Throws: An error of type SuiError indicating that the provided PublicKey is invalid and cannot be converted to an AccountAddress instance.
    public static func fromKey(_ key: any PublicKeyProtocol) throws -> AccountAddress {
        return try AccountAddress(address: key.key)
    }

    /// Create an AccountAddress instance from a MultiPublicKey.
    ///
    /// This function creates an AccountAddress instance from a provided MultiPublicKey. The function generates a new address by appending the Multi ED25519 authorization key
    /// scheme value to the byte representation of the provided MultiPublicKey, and then computes the SHA3-256 hash of the resulting byte array. The resulting hash is used to create
    /// a new AccountAddress instance.
    ///
    /// - Parameters:
    ///    - keys: A MultiPublicKey instance representing the multiple public keys to create the AccountAddress instance from.
    ///
    /// - Returns: An AccountAddress instance created from the provided MultiPublicKey.
    ///
    /// - Throws: An error of type SuiError indicating that the provided MultiPublicKey is invalid and cannot be converted to an AccountAddress instance.
    public static func fromMultiEd25519(keys: MultiPublicKey) throws -> AccountAddress {
        let keysBytes = keys.toBytes()
        var addressBytes = Data(count: keysBytes.count + 1)
        addressBytes[0..<keysBytes.count] = keysBytes[0..<keysBytes.count]
        addressBytes[keysBytes.count] = AuthKeyScheme.multiEd25519
        let result = try Blake2.hash(.b2b, size: 32, data: addressBytes)

        return try AccountAddress(address: result)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> AccountAddress {
        return try AccountAddress(address: deserializer.fixedBytes(length: AccountAddress.length))
    }

    public func serialize(_ serializer: Serializer) throws {
        serializer.fixedBytes(self.address)
    }
}
