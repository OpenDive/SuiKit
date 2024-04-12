//
//  Data.swift
//  SuiKit
//
//  Copyright (c) 2024 OpenDive
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

import CommonCrypto
import Foundation

extension Data {
    /// Converts hexadecimal string representation of some bytes into actual bytes.
    /// Notes:
    ///  - empty string will return `nil`;
    ///  - empty hex string, meaning it's equal to `"0x"`, will return empty `Data` object.
    /// - Parameter hex: bytes represented as string.
    /// - Returns: optional raw bytes.
    public static func fromHex(_ hex: String) -> Data? {
        let hex = hex.lowercased().trim()
        guard !hex.isEmpty else { return nil }
        guard hex != "0x" else { return Data() }
        let bytes = [UInt8](hex: hex.stripHexPrefix())
        return bytes.isEmpty ? nil : Data(bytes)
    }
    
    func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(self.count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        var data: Data
        if isNegative {
            data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
        } else {
            data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
        }
        data.append(self)
        return data
    }

    func setLengthRight(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(self.count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        var data: Data = Data()
        data.append(self)
        if isNegative {
            data.append(Data(repeating: UInt8(255), count: Int(toBytes - existingLength)))
        } else {
            data.append(Data(repeating: UInt8(0), count: Int(toBytes - existingLength)))
        }
        return data
    }
}

public extension Data {
    /// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
    func checksum() -> UInt16 {
        let s = withUnsafeBytes { buf in
            buf.lazy.map(UInt32.init).reduce(UInt32(0), +)
        }
        return UInt16(s % 65535)
    }

    func base64urlEncodedString() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}

public extension Data {
    init(hex: String) {
        self.init([UInt8](hex: hex))
    }

    var bytes: [UInt8] {
        Array(self)
    }

    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    static func fromBase64(_ encoded: String) -> Data? {
        return Data(base64Encoded: encoded);
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

        guard actualOffset <= self.count else {
            throw NSError(
                domain: "Invalid offset",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Offset exceeds Data's length."]
            )
        }

        let end = actualOffset + bytes.count
        if end > self.count {
            let additionalCount = end - self.count
            self.append(Data(repeating: 0, count: additionalCount))
        }

        for i in 0..<bytes.count {
            self[actualOffset + i] = bytes[i]
        }
    }
}
