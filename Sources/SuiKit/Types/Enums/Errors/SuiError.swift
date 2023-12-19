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

/// `SuiError` represents a collection of errors that can occur within the Sui blockchain ecosystem.
public enum SuiError: Error, Equatable {
    /// Indicates that a rate limit error has occurred with a faucet service.
    case faucetRateLimitError

    /// Indicates that the provided JSON data is invalid.
    case invalidJsonData

    /// Indicates that a private key is missing where it's required.
    case missingPrivateKey

    /// Indicates that the length of the provided address is invalid.
    case invalidAddressLength

    /// Indicates that a certain feature or operation is not implemented.
    case notImplemented

    /// Indicates that an error occurred during data encoding.
    case encodingError

    /// Indicates that the provided URL is invalid. The invalid URL is provided as an associated value.
    case invalidUrl(url: String)

    /// Indicates that the provided coin type is invalid.
    case invalidCoinType

    /// Indicates that a URL for the faucet service is required.
    case faucetUrlRequired

    /// Indicates that the operation failed due to some unspecified data issue.
    case failedData

    /// Indicates that the result of an operation is invalid.
    case invalidResult

    /// Indicates that an RPC (Remote Procedure Call) error has occurred. The error details are provided as an associated value.
    case rpcError(error: RPCErrorValue)

    /// Indicates that an invalid module was provided. The invalid input is provided as an associated value.
    case invalidModule(input: String)

    /// Indicates that no data was found where it was expected.
    case noData

    /// Indicates that the data could not be converted to bytes.
    case unableToConvertToBytes

    /// Indicates that the data could not be deserialized.
    case unableToDeserialize

    /// Indicates that the provided address is too long. The invalid address is provided as an associated value.
    case addressTooLong(input: String)

    /// Indicates that a value is nil where it should not be.
    case valueIsNil

    /// Indicates that an object could not be encoded.
    case objectCannotBeEncoded

    /// Indicates that the gas payment specified is too high.
    case gasPaymentTooHigh

    /// Indicates that the protocol configuration could not be found.
    case cannotFindProtocolConfig

    /// Indicates that a required attribute could not be found.
    case cannotFindAttribute

    /// Indicates that the sender of a transaction is missing.
    case senderIsMissing

    /// Indicates that the owner responsible for gas payment cannot be found.
    case gasOwnerCannotBeFound

    /// Indicates that the owner does not have enough coins for payment.
    case ownerDoesNotHavePaymentCoins

    /// Indicates that the size of a move call does not match expectations.
    case moveCallSizeDoesNotMatch

    /// Indicates that the provided input value is not an Object ID.
    case inputValueIsNotObjectId

    /// Indicates that the type of a call argument is unknown.
    case unknownCallArgType

    /// Indicates that the service provider could not be found.
    case providerNotFound

    /// Indicates that an object is invalid.
    case objectIsInvalid

    /// Indicates that a dry run of an operation failed.
    case failedDryRun

    /// Indicates that gas values for a transaction are missing.
    case missingGasValues

    /// Indicates that a type argument is empty.
    case typeArgumentIsEmpty

    /// Indicates that an address could not be validated.
    case unableToValidateAddress

    /// Indicates that a digest is invalid.
    case invalidDigest

    /// Indicates that provided digests do not match.
    case digestsDoNotMatch

    /// Indicates that JSON data could not be parsed.
    case unableToParseJson

    /// Indicates that a transaction has timed out.
    case transactionTimedOut

    /// Indicates that the signature type could not be found.
    case cannotFindSignatureType

    /// Indicates that the key number could not be found.
    case cannotFindKeyNumber

    /// `KioskOwnerCap` is still needing to be transferred.
    case kioskOwnerCapNotTransferred(message: String)

    /// One of the input values for the transfer policy client are nil.
    case invalidTransferPolicyInput(message: String)

    /// Invalid Transfer Policy.
    case invalidTransferPolicy

    /// Invalid Sui Address.
    case invalidSuiAddress

    /// Invalid Object Argument conversion.
    case invalidObjectArgument

    /// The string to number casting is invalid.
    case invalidNumber

    /// The Kiosk Data is invalid.
    case invalidKioskData
}
