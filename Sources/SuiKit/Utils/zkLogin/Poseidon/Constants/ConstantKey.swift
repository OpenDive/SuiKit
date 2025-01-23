//
//  ConstantKey.swift
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

public struct ConstantKey {
    public let C: [String]
    public let M: [[String]]

    public func unstringifyBigInts() -> ([BigInt], [[BigInt]]) {
        let _C: [BigInt] = self.C.map { self.decodeBase64(input: $0) }
        let _M: [[BigInt]] = self.M.map { $0.map { self.decodeBase64(input: $0) } }
        return (_C, _M)
    }

    private func decodeBase64(input: String) -> BigInt {
        // Decode the base64 string to Data
        let data = Data(base64Encoded: input)!

        // Convert data to byte array
        let byteArray = [UInt8](data)

        // Convert byte array to hexadecimal string
        let hexString = byteArray.map { String(format: "%02x", $0) }.joined()

        // Convert hexadecimal string to BigInt
        return BigInt(hexString, radix: 16)!
    }
}
