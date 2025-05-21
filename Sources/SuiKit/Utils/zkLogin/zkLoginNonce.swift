//
//  zkLoginNonce.swift
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
import BigInt
import Security

public struct zkLoginNonce {
    public static let nonceLength = 27

    public static func toBigIntBE(bytes: Data) -> BigInt {
        let hex = bytes.hexEncodedString()
        guard !(hex.isEmpty) else { return BigInt(0) }
        return BigInt(hex, radix: 16)!
    }

    public static func generateRandomness() -> String {
        return Self.toBigIntBE(bytes: Data(Self.randomBytes(count: 16)!)).description
    }

    public static func generateNonce(publicKey: any PublicKeyProtocol, maxEpoch: Int, randomness: String) throws -> String {
        let publicKeyBytes = try Self.toBigIntBE(bytes: Data(publicKey.toSuiBytes()))
        let ephPublicKey0 = publicKeyBytes / BigInt(2).power(128)
        let ephPublicKey1 = publicKeyBytes % BigInt(2).power(128)
        let bigNum = try PoseidonUtilities.poseidonHash(inputs: [ephPublicKey0, ephPublicKey1, BigInt(maxEpoch), BigInt(randomness, radix: 10)!])
        let z = zkLoginUtilities.toBigEndianBytes(num: bigNum, width: 20)
        let nonce = Data(z).base64urlEncodedString()
        guard nonce.count == Self.nonceLength else { throw SuiError.customError(message: "Invalid nonce length") }
        return nonce
    }

    private static func randomBytes(count: Int) -> [UInt8]? {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)

        if status == errSecSuccess {
            return bytes
        } else {
            return nil
        }
    }
}
