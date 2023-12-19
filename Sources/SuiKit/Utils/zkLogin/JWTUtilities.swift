//
//  JWTUtilities.swift
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

public struct JWTUtilities {
    public static func base64UrlCharTo6Bits(base64UrlChar: String) throws -> [Int] {
        // Check for valid input
        guard base64UrlChar.count == 1 else {
            throw NSError(domain: "Invalid base64Url character: \(base64UrlChar)", code: 0, userInfo: nil)
        }

        // Define the base64URL character set
        let base64UrlCharacterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

        // Find the index of the input character in the base64URL character set
        guard let index = base64UrlCharacterSet.firstIndex(of: Character(base64UrlChar)) else {
            throw NSError(domain: "Invalid base64Url character: \(base64UrlChar)", code: 0, userInfo: nil)
        }

        // Convert the index to a 6-bit binary string
        let binaryString = String(
            base64UrlCharacterSet.distance(
                from: base64UrlCharacterSet.startIndex,
                to: index
            ),
            radix: 2
        ).leftPad(toLength: 6, withPad: "0")

        // Convert the binary string to an array of bits
        let bits = binaryString.map { Int(String($0))! }

        return bits
    }

    public static func base64UrlStringToBitVector(base64UrlString: String) throws -> [Int] {
        var bitVector: [Int] = []

        for char in base64UrlString {
            let bits = try Self.base64UrlCharTo6Bits(base64UrlChar: String(char))
            bitVector += bits
        }

        return bitVector
    }

    public static func decodeBase64URL(s: String, i: Int) throws -> String {
        // Check if the input string is too short
        guard s.count >= 2 else {
            throw NSError(domain: "Input (s = \(s)) is not tightly packed because s.length < 2", code: 0, userInfo: nil)
        }

        var bits = try Self.base64UrlStringToBitVector(base64UrlString: s)

        let firstCharOffset = i % 4
        switch firstCharOffset {
        case 1:
            bits = Array(bits.dropFirst(2))
        case 2:
            bits = Array(bits.dropFirst(4))
        case 3:
            throw NSError(domain: "Input (s = \(s)) is not tightly packed because i%4 = 3 (i = \(i))", code: 0, userInfo: nil)
        default:
            break // For 0, do nothing
        }

        let lastCharOffset = (i + s.count - 1) % 4
        switch lastCharOffset {
        case 2:
            bits = Array(bits.dropLast(2))
        case 1:
            bits = Array(bits.dropLast(4))
        case 0:
            throw NSError(domain: "Input (s = \(s)) is not tightly packed because (i + s.count - 1)%4 = 0 (i = \(i))", code: 0, userInfo: nil)
        default:
            break // For 3, do nothing
        }

        guard bits.count % 8 == 0 else {
            throw NSError(domain: "We should never reach here...", code: 0, userInfo: nil)
        }

        var bytes = [UInt8]()
        for chunkStart in stride(from: 0, to: bits.count, by: 8) {
            let byteBits = bits[chunkStart..<min(chunkStart + 8, bits.count)]
            let byte = UInt8(byteBits.reduce(0) { ($0 << 1) | $1 })
            bytes.append(byte)
        }

        return String(data: Data(bytes), encoding: .utf8) ?? ""
    }

    public static func verifyExtendedClaim(claim: String) throws -> (String, Any) {
        // Check the last character of the claim
        guard let lastChar = claim.last, lastChar == "}" || lastChar == "," else {
            throw NSError(domain: "Invalid claim", code: 0, userInfo: nil)
        }

        // Prepare the string for JSON parsing
        let jsonStr = "{" + String(claim.dropLast()) + "}"

        // Parse the JSON
        guard let data = jsonStr.data(using: .utf8),
              let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              jsonObject.keys.count == 1 else {
            throw NSError(domain: "Invalid claim", code: 0, userInfo: nil)
        }

        // Extract key and value
        guard let key = jsonObject.keys.first else {
            throw NSError(domain: "Invalid claim", code: 0, userInfo: nil)
        }

        return (key, jsonObject[key]!)
    }

    public static func extractClaimValue<R>(claim: JWTClaim, claimName: String) throws -> R {
        let extendedClaim = try Self.decodeBase64URL(s: claim.value, i: Int(claim.indexMod4))
        let (name, value) = try Self.verifyExtendedClaim(claim: extendedClaim)

        guard name == claimName else {
            throw NSError(domain: "Invalid field name: found \(name) expected \(claimName)", code: 0, userInfo: nil)
        }

        guard let returnValue = value as? R else {
            throw NSError(domain: "Invalid type conversion", code: 0, userInfo: nil)
        }

        return returnValue
    }
}
