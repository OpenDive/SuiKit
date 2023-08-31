//
//  AccountError.swift
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

public enum AccountError: Error, Equatable {
    case invalidPublicKey
    case lengthMismatch
    case invalidLength
    case invalidSignature
    case invalidSerializedSignature
    case invalidParsedSignature
    case invalidParsedPublicKey
    case invalidData
    case invalidContext
    case invalidPubKeyCreation
    case invalidGeneratedKey
    case invalidDerivationPath
    case invalidMnemonicSeed
    case invalidHDNode
    case invalidHardenedPath
    case invalidCurveData
    case keysCountOutOfRange(min: Int, max: Int)
    case thresholdOutOfRange(min: Int, max: Int)
    case noContentInKey
    case failedData
    case cannotBeDeserialized
    case cannotBeSerialized
    case cannotBeExported
}
