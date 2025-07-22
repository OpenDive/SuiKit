//
//  Array.swift
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

extension Array {
    @inlinable
    init(reserveCapacity: Int) {
        self = [Element]()
        self.reserveCapacity(reserveCapacity)
    }

    @inlinable
    var slice: ArraySlice<Element> {
        self[startIndex ..< endIndex]
    }

    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        guard !isEmpty else { return [] }

        let chunkCount = (count + size - 1) / size  // Ceiling division
        var result: [[Element]] = []
        result.reserveCapacity(chunkCount)

        for i in stride(from: 0, to: count, by: size) {
            let endIndex = Swift.min(i + size, count)
            result.append(Array(self[i..<endIndex]))
        }

        return result
    }

    /// More memory-efficient chunking using lazy evaluation
    func chunkedLazy(into size: Int) -> LazyMapSequence<StrideTo<Int>, ArraySlice<Element>> {
        return stride(from: 0, to: count, by: size).lazy.map { start in
            let endIndex = Swift.min(start + size, count)
            return self[start..<endIndex]
        }
    }

    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element == UInt8 {
    init(hex: String) {
        let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        let hexLength = cleanHex.count

        // Pre-allocate capacity
        self.init()
        self.reserveCapacity((hexLength + 1) / 2)

        var buffer: UInt8?

        for char in cleanHex.utf8 {
            let value: UInt8?

            switch char {
            case 48...57:  // '0'...'9'
                value = char - 48
            case 65...70:  // 'A'...'F'
                value = char - 55
            case 97...102: // 'a'...'f'
                value = char - 87
            default:
                removeAll()
                return
            }

            guard let v = value else {
                removeAll()
                return
            }

            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }

        // Handle odd-length hex strings
        if let b = buffer {
            append(b)
        }
    }

    internal func bytesToString(includeLength: Bool = true) -> String {
        var startIndex = 0
        if includeLength { startIndex = 1 }
        return self[startIndex...].reduce("") { result, byte in
            return result + String(format: "%02x", byte)
        }
    }

    mutating func set(_ bytes: [UInt8], offset: Int? = nil) throws {
        let actualOffset = offset ?? 0
        guard actualOffset >= 0 else {
            throw NSError(
                domain: "Invalid offset",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Offset can't be negative."]
            )
        }
        let end = actualOffset + bytes.count
        if end > self.count {
            self += [UInt8](repeating: 0, count: end - self.count)
        }
        for i in 0..<bytes.count {
            self[i + actualOffset] = bytes[i]
        }
    }

    func toHexString() -> String {
        // Pre-allocate string capacity for better performance
        var result = String()
        result.reserveCapacity(count * 2)

        for byte in self {
            result += String(format: "%02x", byte)
        }
        return result
    }

    /// High-performance hex string conversion using unsafe buffer operations
    func toHexStringFast() -> String {
        let hexChars: [UInt8] = [
            48, 49, 50, 51, 52, 53, 54, 55, 56, 57,  // 0-9
            97, 98, 99, 100, 101, 102                // a-f
        ]

        return String(unsafeUninitializedCapacity: count * 2) { buffer in
            var index = 0
            for byte in self {
                buffer[index] = hexChars[Int(byte >> 4)]
                buffer[index + 1] = hexChars[Int(byte & 0x0F)]
                index += 2
            }
            return count * 2
        }
    }
}

public extension Array where Element == UInt8 {
    func toBase64() -> String {
        Data(self).base64EncodedString()
    }

    init(base64: String) {
        self.init()
        guard let decodedData = Data(base64Encoded: base64) else {
            return
        }
        append(contentsOf: decodedData.bytes)
    }
}

/// Extension on Array of UInt8 to convert to and from various string representations
public extension Array where Element == UInt8 {
    /// Convert an array of UInt8 to a base58 string
    func toBase58String() -> String {
        // Base58 alphabet
        let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

        let bytes = self
        var zerosCount = 0

        // Count leading zeros
        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        // Convert to BigInt
        var num = BigInt(0)
        for byte in bytes {
            num = num * 256 + BigInt(byte)
        }

        // Convert to base58
        var result = ""
        while num > 0 {
            let (quotient, remainder) = num.quotientAndRemainder(dividingBy: 58)
            result = String(alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(remainder))]) + result
            num = quotient
        }

        // Add leading zeros
        for _ in 0..<zerosCount {
            result = "1" + result
        }

        return result
    }

    /// Initialize an array of UInt8 from a base58 string
    init?(base58: String) {
        let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

        // Count leading 1s (zeros in base58)
        var zerosCount = 0
        for c in base58 {
            if c != "1" { break }
            zerosCount += 1
        }

        // Convert from base58
        var num = BigInt(0)
        for c in base58 {
            guard let idx = alphabet.firstIndex(of: c) else {
                return nil
            }
            num = num * 58 + BigInt(alphabet.distance(from: alphabet.startIndex, to: idx))
        }

        // Convert to bytes
        var bytes = [UInt8]()
        while num > 0 {
            let (quotient, remainder) = num.quotientAndRemainder(dividingBy: 256)
            bytes.insert(UInt8(remainder), at: 0)
            num = quotient
        }

        // Add leading zeros
        for _ in 0..<zerosCount {
            bytes.insert(0, at: 0)
        }

        self = bytes
    }
}
