//
//  Wallet.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
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
import ed25519swift
import CryptoSwift
import Bip39

/// Represents a Sui wallet, capable of managing multiple accounts.
public class Wallet: Hashable {
    /// The mnemonic associated with the wallet, represented by a `Mnemonic` instance.
    public var mnemonic: Mnemonic

    /// An array of `Account` instances representing the accounts in the wallet.
    public var accounts: [Account]

    /// Convenience initializer to create a `Wallet` instance with a new mnemonic.
    /// - Throws: An error if there is any issue creating the mnemonic or initializing the wallet with it.
    public convenience init() throws {
        let mnemonic = try Mnemonic() // Generates a new mnemonic.
        try self.init(mnemonic: mnemonic) // Initializes the wallet with the newly created mnemonic.
    }

    /// Initializes a new wallet with the given mnemonic and accounts.
    /// - Parameters:
    ///   - mnemonic: The mnemonic associated with the wallet.
    ///   - accounts: The accounts to be included in the wallet.
    public init(mnemonic: Mnemonic, accounts: [Account]) {
        self.mnemonic = mnemonic
        self.accounts = accounts
    }

    /// Initializes a new wallet with the given mnemonic and a single account of the specified type.
    /// - Parameters:
    ///   - mnemonic: The mnemonic associated with the wallet.
    ///   - accountType: The type of account to be created in the wallet, defaulting to `.ed25519`.
    ///   - separator: The string that separates the mnemonic words, defaulting to " ".
    /// - Throws: An error if there is any issue creating the account with the given mnemonic and account type.
    public init(mnemonic: Mnemonic, accountType: KeyType = .ed25519, separator: String = " ") throws {
        self.mnemonic = mnemonic
        self.accounts = [
            try Account(
                mnemonic.mnemonic().joined(separator: separator),
                accountType: accountType
            ) // Creates a new account with the specified mnemonic and account type.
        ]
    }

    /// Convenience initializer to create a `Wallet` instance with a mnemonic string.
    /// - Parameters:
    ///   - mnemonicString: A string representation of the mnemonic.
    ///   - accountType: The type of account to be created in the wallet, defaulting to `.ed25519`.
    ///   - separator: The string that separates the mnemonic words in `mnemonicString`, defaulting to " ".
    /// - Throws: An error if there is any issue creating the mnemonic or initializing the wallet with it.
    public convenience init(
        mnemonicString: String,
        accountType: KeyType = .ed25519,
        separator: String = " "
    ) throws {
        let mnemonic = try Mnemonic(mnemonic: mnemonicString.components(separatedBy: separator)) // Parses the mnemonic string.
        try self.init(mnemonic: mnemonic, accountType: accountType, separator: separator) // Initializes the wallet with the parsed mnemonic.
    }

    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return
            lhs.mnemonic == rhs.mnemonic &&
            lhs.accounts == rhs.accounts
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.accounts)
        hasher.combine(self.mnemonic)
    }
}
