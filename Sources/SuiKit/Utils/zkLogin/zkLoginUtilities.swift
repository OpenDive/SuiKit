//
//  zkLoginUtilities.swift
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
import Blake2
import JWTDecode

public struct zkLoginUtilities {
    public static let maxHeaderLengthBase64 = 248
    public static let maxPaddedUnsignedJwtLength = 64 * 25
    public static let maxKeyClaimNameLength = 32
    public static let maxKeyClaimValueLength = 115
    public static let maxAudValueLength = 145
    public static let packWidth = 248

    public static func toBigEndianBytes(num: BigInt, width: Int) -> [UInt8] {
        let bytes = Self.toPaddedBigEndianBytes(num: num, width: width)
        let firstNonZeroIndex = Self.findFirstNonZeroIndex(bytes: bytes)
        if firstNonZeroIndex == -1 { return [0] }
        return Array(bytes[firstNonZeroIndex...])
    }

    public static func toPaddedBigEndianBytes(num: BigInt, width: Int) -> [UInt8] {
        let hex = String(num, radix: 16)
        let paddedHex = String(repeating: "0", count: max(0, width * 2 - hex.count)) + hex
        let finalHex = paddedHex.suffix(width * 2)
        return stride(from: 0, to: width * 2, by: 2).map {
            let startIndex = finalHex.index(finalHex.startIndex, offsetBy: $0)
            let endIndex = finalHex.index(startIndex, offsetBy: 2)
            let byteString = finalHex[startIndex..<endIndex]
            return UInt8(byteString, radix: 16)!
        }
    }

    public static func findFirstNonZeroIndex(bytes: [UInt8]) -> Int {
        for (idx, num) in bytes.enumerated() {
            if num != 0 { return idx }
        }
        return -1
    }

    public static func chunkArray<T>(_ array: [T], chunkSize: Int) -> [[T]] {
        guard chunkSize > 0 else { return [] }

        var chunks = [[T]]()
        let reversedArray = array.reversed()
        let chunkCount = Int(ceil(Double(array.count) / Double(chunkSize)))

        for i in 0..<chunkCount {
            let chunk = reversedArray
                .dropFirst(i * chunkSize)
                .prefix(chunkSize)
                .reversed()
            chunks.append(Array(chunk))
        }

        return chunks.reversed()
    }

    public static func bytesBEToBigInt(bytes: [UInt8]) -> BigInt {
        let hexString = bytes.map { String(format: "%02x", $0) }.joined()

        // Handling the case where hexString is empty
        guard !hexString.isEmpty else {
            return BigInt(0)
        }

        return BigInt(hexString, radix: 16) ?? BigInt(0)
    }

    public static func hashASCIIStrToField(str: String, maxSize: Int) throws -> BigInt {
        guard str.count <= maxSize else {
            throw NSError(domain: "String \(str) is longer than \(maxSize) chars", code: -1, userInfo: nil)
        }

        // Padding the string
        let paddedStr = str.padding(toLength: maxSize, withPad: "\0", startingAt: 0)

        // Convert string to array of ASCII values
        let asciiValues = Array(paddedStr).map { UInt8($0.asciiValue ?? 0) }

        // Define chunkSize (assuming PACK_WIDTH is already defined)
        let chunkSize = Self.packWidth / 8

        // Chunk the ASCII array and convert each chunk to BigInt
        let chunks = chunkArray(asciiValues, chunkSize: chunkSize)
        let packed = chunks.map { bytesBEToBigInt(bytes: $0) }

        // Hashing the array of BigInts (assuming poseidonHash is already implemented)
        return try PoseidonUtilities.poseidonHash(inputs: packed)
    }

    public static func genAddressSeed(
        _salt: String,
        name: String,
        value: String,
        aud: String,
        maxNameLength: Int = Self.maxKeyClaimNameLength,
        maxValueLength: Int = Self.maxKeyClaimValueLength,
        maxAudLength: Int = Self.maxAudValueLength
    ) throws -> BigInt {
        let salt = BigInt(_salt, radix: 10)!
        return try PoseidonUtilities.poseidonHash(inputs: [
            Self.hashASCIIStrToField(str: name, maxSize: maxNameLength),
            Self.hashASCIIStrToField(str: value, maxSize: maxValueLength),
            Self.hashASCIIStrToField(str: aud, maxSize: maxAudLength),
            PoseidonUtilities.poseidonHash(inputs: [salt])
        ])
    }

    /// Generate an address seed for zkLogin authentication
    /// - Parameters:
    ///   - salt: User's salt value
    ///   - keyClaimName: Name of the key claim (typically "sub")
    ///   - keyClaimValue: Value of the key claim (typically the user ID)
    ///   - audience: The audience value from the JWT
    /// - Returns: A BigInt representing the address seed
    public static func generateAddressSeed(
        salt: String,
        keyClaimName: String,
        keyClaimValue: String,
        audience: String
    ) throws -> String {
        // Generate the address seed
        let addressSeed = try genAddressSeed(
            _salt: salt,
            name: keyClaimName,
            value: keyClaimValue,
            aud: audience
        )

        // Return as string (BigInt description)
        return addressSeed.description
    }

    public static func lengthChecks(jwt: String) throws {
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { throw SuiError.customError(message: "Invalid JWT format") }

        let header = parts[0]
        let payload = parts[1]

        // Check if the header is small enough
        if header.count > Self.maxHeaderLengthBase64 {
            throw SuiError.customError(message: "Header too large")
        }

        // Check if the combined length of (header, payload, SHA2 padding) is small enough
        let L = (header.count + 1 + payload.count) * 8
        let K = (512 + 448 - ((L % 512) + 1)) % 512
        let paddedUnsignedJwtLen = (L + 1 + K + 64) / 8

        if paddedUnsignedJwtLen > Self.maxPaddedUnsignedJwtLength {
            throw SuiError.customError(message: "JWT too large")
        }
    }

    public static func jwtToAddress(jwt: String, userSalt: String) throws -> String {
        try Self.lengthChecks(jwt: jwt)

        let decodedJwt = try decode(jwt: jwt)
        guard
            let sub = decodedJwt.body["sub"] as? String,
            let iss = decodedJwt.body["iss"] as? String,
            let aud = decodedJwt.body["aud"] as? String
        else { throw SuiError.customError(message: "Invalid JWT format") }

        return try Self.computezkLoginAddress(
            claimName: "sub",
            claimValue: sub,
            userSalt: userSalt,
            iss: iss,
            aud: aud
        )
    }

    public static func computezkLoginAddress(
        claimName: String,
        claimValue: String,
        userSalt: String,
        iss: String,
        aud: String
    ) throws -> String {
        return try zkLoginPublicIdentifier(
            addressSeed: Self.genAddressSeed(
                _salt: userSalt,
                name: claimName,
                value: claimValue,
                aud: aud
            ),
            iss: iss
        ).toSuiAddress()
    }
}
