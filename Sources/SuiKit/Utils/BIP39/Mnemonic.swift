//
//  Mnemonic.swift
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
import CryptoSwift

/// Used for deriving BIP39 Phrases
public class Mnemonic {
    public enum Error: Swift.Error {
        case invalidMnemonic
        case invalidEntropy
    }

    /// Contains the seed phrases themselves
    public let phrase: [String]

    /// Used for storing the user's passphrase
    let passphrase: String

    public init(strength: Int = 256, wordlist: [String] = Wordlists.english) {
        precondition(strength % 32 == 0, "Invalid entropy")

        // Generates random bytes to use as entropy for the mnemonic phrase.
        var bytes = [UInt8](repeating: 0, count: strength / 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        // Converts the bytes into a mnemonic phrase by adding a checksum and converting the resulting binary string into words using the specified wordlist.
        let entropyBits = String(bytes.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits

        var phrase = [String]()
        for i in 0 ..< (bits.count / 11) {
            // Extracts each 11-bit index from the binary string and converts it into a word using the specified wordlist.
            let wi = Int(
                bits[bits.index(bits.startIndex, offsetBy: i * 11) ..< bits
                    .index(bits.startIndex, offsetBy: (i + 1) * 11)],
                radix: 2
            )!
            phrase.append(String(wordlist[wi]))
        }

        // Assigns the generated mnemonic phrase to the instance variable `phrase` and sets `passphrase` to an empty string.
        self.phrase = phrase
        passphrase = ""
    }

    public init(wordcount: Int = 12, wordlist: [String] = Wordlists.english) {
        var strength: Int = 128

        switch wordcount {
            // If wordcount is 15, sets strength to 160 bits. If wordcount is 18, sets strength to 192 bits. If wordcount is 21, sets strength to 224 bits. Otherwise, sets strength to 128 bits.
            case 15: strength = 160
            case 18: strength = 192
            case 21: strength = 224
            default: strength = 128
        }

        // If wordcount is less than 12, sets strength to 128 bits. If wordcount is greater than 24, sets strength to 256 bits.
        if wordcount < 12 { strength = 128 }
        if wordcount > 24 { strength = 256 }

        // Generates random bytes to use as entropy for the mnemonic phrase.
        var bytes = [UInt8](repeating: 0, count: strength / 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        // Converts the bytes into a mnemonic phrase by adding a checksum and converting the resulting binary string into words using the specified wordlist.
        let entropyBits = String(bytes.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits

        var phrase = [String]()
        for i in 0 ..< (bits.count / 11) {
            // Extracts each 11-bit index from the binary string and converts it into a word using the specified wordlist.
            let wi = Int(
                bits[bits.index(bits.startIndex, offsetBy: i * 11) ..< bits
                    .index(bits.startIndex, offsetBy: (i + 1) * 11)],
                radix: 2
            )!
            phrase.append(String(wordlist[wi]))
        }

        // Assigns the generated mnemonic phrase to the instance variable `phrase` and sets `passphrase` to an empty string.
        self.phrase = phrase
        passphrase = ""
    }

    public init(phrase: [String], passphrase: String = "") throws {
        if !Mnemonic.isValid(phrase: phrase) {
            throw Error.invalidMnemonic
        }
        self.phrase = phrase
        self.passphrase = passphrase
    }

    public init(entropy: [UInt8], wordlist: [String] = Wordlists.english, passphrase: String = "") throws {
        self.phrase = try Mnemonic.toMnemonic(entropy, wordlist: wordlist)
        self.passphrase = passphrase
    }

    /// Converts an array of bytes to a list of mnemonic words using a specified wordlist.
    ///
    /// - Parameters:
    ///    - bytes: An array of bytes to be converted to a mnemonic phrase.
    ///    - wordlist: An optional parameter specifying the wordlist to be used. If not provided, the default English wordlist will be used.
    ///
    /// - Returns: A list of mnemonic words representing the input bytes.
    ///
    /// - Throws: Any error thrown by Mnemonic.deriveChecksumBits() function if there is an issue calculating the checksum bits.
    public static func toMnemonic(_ bytes: [UInt8], wordlist: [String] = Wordlists.english) throws -> [String] {
        let entropyBits = String(bytes.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits

        var phrase = [String]()
        for i in 0 ..< (bits.count / 11) {
            let wi = Int(
                bits[bits.index(bits.startIndex, offsetBy: i * 11) ..< bits
                    .index(bits.startIndex, offsetBy: (i + 1) * 11)],
                radix: 2
            )!
            phrase.append(String(wordlist[wi]))
        }
        return phrase
    }

    /// Converts a list of mnemonic words to an array of bytes.
    ///
    /// - Parameters:
    ///    - phrase: A list of mnemonic words to be converted to an array of bytes.
    ///    - wordlist: An optional parameter specifying the wordlist to be used. If not provided, the default English wordlist will be used.
    ///
    /// - Returns: An array of bytes representing the input mnemonic phrase.
    ///
    /// - Throws: An Error.invalidMnemonic error if the checksum of the input mnemonic phrase does not match the expected checksum.
    public static func toEntropy(_ phrase: [String], wordlist: [String] = Wordlists.english) throws -> [UInt8] {
        let bits = phrase.map { word -> String in
            let index = wordlist.firstIndex(of: word)!
            var str = String(index, radix: 2)
            while str.count < 11 {
                str = "0" + str
            }
            return str
        }.joined(separator: "")

        let dividerIndex = Int(Double(bits.count / 33).rounded(.down) * 32)
        let entropyBits = String(bits.prefix(dividerIndex))
        let checksumBits = String(bits.suffix(bits.count - dividerIndex))

        let regex = try! NSRegularExpression(pattern: "[01]{1,8}", options: .caseInsensitive)
        let entropyBytes = regex.matches(
            in: entropyBits,
            options: [],
            range: NSRange(location: 0, length: entropyBits.count)
        ).map {
            UInt8(strtoul(String(entropyBits[Range($0.range, in: entropyBits)!]), nil, 2))
        }
        if checksumBits != Mnemonic.deriveChecksumBits(entropyBytes) {
            throw Error.invalidMnemonic
        }
        return entropyBytes
    }

    /// Checks if a given mnemonic phrase is valid based on a specified wordlist.
    ///
    /// - Parameters:
    ///    - phrase: A list of mnemonic words to be validated.
    ///    - wordlist: An optional parameter specifying the wordlist to be used for validation. If not provided, the default English wordlist will be used.
    ///
    /// - Returns: A boolean value indicating whether the input mnemonic phrase is valid according to the specified wordlist.
    ///
    /// - Note: This function does not check if the mnemonic phrase represents a valid wallet or private key. It only checks the validity of the mnemonic words and their corresponding checksum.
    public static func isValid(phrase: [String], wordlist: [String] = Wordlists.english) -> Bool {
        var bits = ""
        for word in phrase {
            guard let i = wordlist.firstIndex(of: word) else { return false }
            bits += ("00000000000" + String(i, radix: 2)).suffix(11)
        }

        let dividerIndex = bits.count / 33 * 32
        let entropyBits = String(bits.prefix(dividerIndex))
        let checksumBits = String(bits.suffix(bits.count - dividerIndex))

        let regex = try! NSRegularExpression(pattern: "[01]{1,8}", options: .caseInsensitive)
        let entropyBytes = regex.matches(
            in: entropyBits,
            options: [],
            range: NSRange(location: 0, length: entropyBits.count)
        ).map {
            UInt8(strtoul(String(entropyBits[Range($0.range, in: entropyBits)!]), nil, 2))
        }
        return checksumBits == deriveChecksumBits(entropyBytes)
    }

    /// Calculates the checksum bits for a given array of bytes.
    ///
    /// - Parameter bytes: An array of bytes for which to calculate the checksum bits.
    ///
    /// - Returns: A string representing the checksum bits.
    ///
    /// - Note: The length of the checksum bits is determined by the number of bits in the input data. The checksum bits are derived by computing the SHA256 hash of the input data and returning a prefix of the resulting hash of length ENT / 32, where ENT is the number of bits in the input data.
    public static func deriveChecksumBits(_ bytes: [UInt8]) -> String {
        let ENT = bytes.count * 8
        let CS = ENT / 32

        let hash = Data(bytes).sha256()
        let hashbits = String(hash.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        return String(hashbits.prefix(CS))
    }

    /// Used for deriving the seed when generating the private and public keys
    public var seed: Data? {
        let mnemonic = (phrase.joined(separator: " ") as NSString).decomposedStringWithCompatibilityMapping
        let salt = (("mnemonic" + passphrase) as NSString).decomposedStringWithCompatibilityMapping
        do {
            let pbkdf2 = try PKCS5.PBKDF2(password: mnemonic.bytes, salt: salt.bytes, iterations: 2048, keyLength: 64, variant: .sha2(.sha512)).calculate()
            return Data(pbkdf2)
        } catch {
            return nil
        }
    }
}

extension Mnemonic: Equatable {
    public static func == (lhs: Mnemonic, rhs: Mnemonic) -> Bool {
        lhs.phrase == rhs.phrase && lhs.passphrase == rhs.passphrase
    }
}
