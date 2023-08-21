//
//  SuiError.swift
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

public enum SuiError: Error, Equatable {
    case FaucetRateLimitError
    case invalidJsonData
    case missingPrivateKey
    case invalidAddressLength
    case notImplemented
    case encodingError
    case invalidUrl(url: String)
    case invalidCoinType
    case faucetUrlRequired
    case failedData
    case invalidResult
    case rpcError(error: RPCErrorValue)
    case invalidModule(input: String)
    case noData
    case unableToConvertToBytes
    case unableToDeserialize
    case addressTooLong(input: String)
    case valueIsNil
    case objectCannotBeEncoded
    case gasPaymentTooHigh
    case cannotFindProtocolConfig
    case cannotFindAttribute
    case senderIsMissing
    case gasOwnerCannotBeFound
    case ownerDoesNotHavePaymentCoins
    case moveCallSizeDoesNotMatch
    case inputValueIsNotObjectId
    case unknownCallArgType
    case providerNotFound
    case objectIsInvalid
    case failedDryRun
    case missingGasValues
    case typeArgumentIsEmpty
    case unableToValidateAddress
    case invalidDigest
    case digestsDoNotMatch
    case unableToParseJson
    case transactionTimedOut
    case cannotFindSignatureType
}
