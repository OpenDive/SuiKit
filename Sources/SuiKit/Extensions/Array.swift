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
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element == UInt8 {
    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48, char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
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
        lazy.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
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
