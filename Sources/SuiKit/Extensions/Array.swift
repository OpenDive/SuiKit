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
