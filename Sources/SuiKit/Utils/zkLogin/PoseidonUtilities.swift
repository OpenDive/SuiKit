//
//  PoseidonUtilities.swift
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

public struct PoseidonUtilities {
    nonisolated(unsafe) private static let poseidonNumToHashFN: [any Poseidon] = [
        Poseidon1(),
        Poseidon2(),
        Poseidon3(),
        Poseidon4(),
        Poseidon5(),
        Poseidon6(),
        Poseidon7(),
        Poseidon8(),
        Poseidon9(),
        Poseidon10(),
        Poseidon11(),
        Poseidon12(),
        Poseidon13(),
        Poseidon14(),
        Poseidon15(),
        Poseidon16()
    ]

    public static func poseidonHash(inputs: [BigInt]) throws -> BigInt {
        let idx = inputs.count - 1
        guard idx >= 0 && idx < (poseidonNumToHashFN.count - 1) else {
            if inputs.count <= 32 {
                let hash1 = try Self.poseidonHash(inputs: Array(inputs.prefix(upTo: 16)))
                let hash2 = try Self.poseidonHash(inputs: Array(inputs.suffix(from: 16)))
                return try Self.poseidonHash(inputs: [hash1, hash2])
            }
            throw SuiError.customError(message: "Poseidon hash not implemented for this input size")
        }
        let hashFN = Self.poseidonNumToHashFN[inputs.count - 1]
        return try hashFN.poseidon(inputs: inputs)
    }
}
