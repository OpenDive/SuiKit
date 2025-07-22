//
//  PoseidonFunction.swift
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

public struct PoseidonFunction {
    let F = BigInt("21888242871839275222246405745257275088548364400416034343698204186575808495617")
    let nRoundsF: Int = 8
    let nRoundsP: [Int] = [56, 57, 56, 60, 60, 63, 64, 63, 60, 66, 60, 65, 70, 60, 64, 68]

    public func poseidon(inputs: [BigInt], C: [BigInt], M: [[BigInt]]) throws -> BigInt {
        guard !inputs.isEmpty, inputs.count <= self.nRoundsP.count else { throw SuiError.notImplemented }
        let t = inputs.count + 1
        let nRoundsF = self.nRoundsF
        let nRoundsP = self.nRoundsP[t - 2]
        guard M.count == t else { throw SuiError.notImplemented }

        var state: [BigInt] = [BigInt(0)]
        state.append(contentsOf: inputs)
        for idxX in 0..<(nRoundsF + nRoundsP) {
            for idxY in 0..<state.count {
                state[idxY] = state[idxY] + C[idxX * t + idxY]
                if idxX < (nRoundsF / 2) || idxX >= (nRoundsF / 2 + nRoundsP) {
                    state[idxY] = self.pow5(v: state[idxY])
                } else if idxY == 0 {
                    state[idxY] = self.pow5(v: state[idxY])
                }
            }
            state = self.mix(state: state, m: M)
        }
        return state[0]
    }

    private func pow5(v: BigInt) -> BigInt {
        let o = v * v
        return BigInt((v * o * o)) % self.F
    }

    private func mix(state: [BigInt], m: [[BigInt]]) -> [BigInt] {
        var out: [BigInt] = []
        for (idxX, _) in state.enumerated() {
            var o: BigInt = BigInt(0)
            for (idxY, _) in state.enumerated() {
                o = o + m[idxX][idxY] * state[idxY]
            }
            out.append(BigInt(o) % self.F)
        }
        return out
    }
}
