//
//  Wallet.swift
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
import ed25519swift
import CryptoSwift
import Bip39

/// Represents an Sui wallet.
public class Wallet: Hashable {
    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return
            lhs.mnemonic == rhs.mnemonic &&
            lhs.accounts == rhs.accounts
    }
    
    /// The mnemonic words.
    public var mnemonic: Mnemonic

    /// The key pair.
    public var accounts: [Account]
    
    public convenience init() throws {
        let mnemonic = try Mnemonic()
        try self.init(mnemonic: mnemonic)
    }
    
    public init(mnemonic: Mnemonic, accounts: [Account]) {
        self.mnemonic = mnemonic
        self.accounts = accounts
    }
    
    public init(mnemonic: Mnemonic, accountType: KeyType = .ed25519, separator: String = " ") throws {
        self.mnemonic = mnemonic
        self.accounts = [
            try Account(
                mnemonic.mnemonic().joined(separator: separator),
                accountType: accountType
            )
        ]
    }
    
    public convenience init(
        mnemonicString: String,
        accountType: KeyType = .ed25519,
        separator: String = " "
    ) throws {
        let mnemonic = try Mnemonic(mnemonic: mnemonicString.components(separatedBy: separator))
        try self.init(mnemonic: mnemonic, accountType: accountType, separator: separator)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.accounts)
        hasher.combine(self.mnemonic)
    }
}
