//
//  Wallet.swift
//  AptosKit
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

/// Represents an Aptos wallet.
public class Wallet: Hashable {
    /// The derivation path.
    private static let derivationPath: String = "m/44'/784'/0'/0'/0'"

    /// The seed derived from the mnemonic and/or passphrase.
    private var _seed: Data? = nil

    /// The method used for ED25519 key generation.
    private var _ed25519Bip32: Ed25519BIP32

    /// The seed mode used for key generation.
    /// Aptos currently supports BIP39
    private var seedMode: SeedMode = .Ed25519Bip32

    /// The passphrase string.
    private var passphrase: String = ""

    /// The mnemonic words.
    public var mnemonic: Mnemonic

    /// The key pair.
    public var account: Account

    public init(wordCount: Int, wordList: [String], passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        self.mnemonic = Mnemonic(wordcount: wordCount, wordlist: wordList)
        self.passphrase = passphrase
        self.seedMode = seedMode
        let seed = mnemonic.seed!
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)

        var privateKey: Data = Data()
        var publicKey: Data = Data()

        if self.seedMode == .Ed25519Bip32 {
            if self.seedMode != .Ed25519Bip32 {
                throw SuiError.seedModeIncompatibleWithEd25519Bip32BasedSeeds(seedMode: seedMode.rawValue)
            }

            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)

        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
        }

        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }

    public init(mnemonic: Mnemonic, passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        self.mnemonic = mnemonic
        self.passphrase = passphrase
        self.seedMode = seedMode
        let seed = mnemonic.seed!
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)

        var privateKey: Data = Data()
        var publicKey: Data = Data()

        if self.seedMode == .Ed25519Bip32 {
            if self.seedMode != .Ed25519Bip32 {
                throw SuiError.seedModeIncompatibleWithEd25519Bip32BasedSeeds(seedMode: seedMode.rawValue)
            }

            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)

        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
        }

        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }

    public init(phrase: [String], passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        self.mnemonic = try Mnemonic(phrase: phrase, passphrase: passphrase)
        self.passphrase = passphrase
        self.seedMode = seedMode
        let seed = mnemonic.seed!
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)

        var privateKey: Data = Data()
        var publicKey: Data = Data()

        if self.seedMode == .Ed25519Bip32 {
            if self.seedMode != .Ed25519Bip32 {
                throw SuiError.seedModeIncompatibleWithEd25519Bip32BasedSeeds(seedMode: seedMode.rawValue)
            }

            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)

        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
        }

        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }

    public init(seed: Data, passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        if seed.count != 64 {
            throw SuiError.invalidSeedLength
        }
        self.passphrase = passphrase
        self.seedMode = seedMode
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)
        self.mnemonic = try Mnemonic(entropy: [UInt8](seed), passphrase: passphrase)

        var privateKey: Data = Data()
        var publicKey: Data = Data()

        if self.seedMode == .Ed25519Bip32 {
            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
            
        }

        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.mnemonic.passphrase)
    }

    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return
            lhs.mnemonic == rhs.mnemonic
    }

    /// Get an Aptos Blockchain account at the specified index from an Ed25519 BIP-32-based seed.
    ///
    /// This function gets an Aptos Blockchain account at the specified index from an Ed25519 BIP-32-based seed, and returns the resulting Account instance.
    ///
    /// - Parameters:
    /// - index: An integer value representing the index of the account to retrieve from the Ed25519 BIP-32-based seed.
    ///
    /// - Returns: An Account instance representing the account at the specified index.
    ///
    /// - Throws: An error of type SuiError indicating that the seed mode is incompatible with Ed25519 BIP-32-based seeds or that an AccountAddress or PrivateKey instance cannot be created from the retrieved public key or private key bytes, respectively.
    public func getAccount(index: Int) throws -> Account {
        if self.seedMode != .Ed25519Bip32 {
            throw SuiError.seedModeIncompatibleWithEd25519Bip32BasedSeeds(seedMode: seedMode.rawValue)
        }

        let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(index))
        var account: Data = Data()
        var privateKey: Data = Data()
        var publicKey: Data = Data()
        (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
        (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
        return Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }
    
    /// Derives the Mnemonic seed from the Mnemonic object.
    /// - Returns: Data representing the seed itself
    public func deriveMnemonicSeed() -> Data {
        if _seed != nil {
            return _seed!
        }

        return mnemonic.seed!
    }

    /// Initialize the first Aptos Blockchain account using the provided seed.
    ///
    /// This function initializes the first Aptos Blockchain account using the provided seed and sets the resulting account as the default account of the Wallet instance. If the seed mode is Ed25519Bip32, the function creates an Ed25519BIP32 instance using the provided seed, gets the first account at index 0 using the getAccount function, and sets it as the default account. Otherwise, the function creates an Account instance using the provided seed and sets it as the default account.
    ///
    /// - Throws: An error of type SuiError indicating that the seed mode is incompatible with Ed25519 BIP-32-based seeds or that an AccountAddress or PrivateKey instance cannot be created from the retrieved public key or private key bytes, respectively.
    private func initializeFirstAccount() throws {
        if let _seed {
            if self.seedMode == .Ed25519Bip32 {
                self._ed25519Bip32 = Ed25519BIP32(seed: _seed)
                self.account = try getAccount(index: 0)
            } else {
                var privateKey: Data = Data()
                var publicKey: Data = Data()
                (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: _seed[0..<32])
                self.account = Account(
                    accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
                    privateKey: PrivateKey(key: privateKey)
                )
            }
        }
    }

    /// Generate an Ed25519 key pair using the provided seed.
    ///
    /// This function generates an Ed25519 key pair using the provided seed, and returns the resulting key pair as a tuple containing the private and public keys.
    ///
    /// - Parameters:
    ///    - seed: A Data object representing the seed value to be used for generating the Ed25519 key pair.
    ///
    /// - Returns: A tuple containing the private and public keys generated from the provided seed.
    private static func edKeyPairFromSeed(seed: Data) -> (privateKey: Data, publicKey: Data) {
        return (privateKey: seed, publicKey: Data(Ed25519.calcPublicKey(secretKey: [UInt8](seed))))
    }
}
