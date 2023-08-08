//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/24/23.
//

import Foundation

public enum SuiError: Swift.Error, Equatable {
    case FaucetRateLimitError
    case invalidPublicKey
    case lengthMismatch
    case unexpectedValue(value: String)
    case stringToDataFailure(value: String)
    case stringToUInt256Failure(value: String)
    case unexpectedLargeULEB128Value(value: String)
    case invalidLength
    case invalidDataValue(supportedType: String)
    case doesNotConformTo(protocolType: String)
    case unexpectedEndOfInput(requested: String, found: String)
    case keysCountOutOfRange(min: Int, max: Int)
    case thresholdOutOfRange(min: Int, max: Int)
    case noContentInKey
    case invalidDerivationPath
    case invalidJsonData
    case missingAccountAddressKey
    case missingPrivateKey
    case invalidAddressLength
    case seedModeIncompatibleWithEd25519Bip32BasedSeeds(seedMode: String)
    case invalidSeedLength
    case notImplemented
    case encodingError
    case invalidUrl(url: String)
    case invalidCoinType
    case invalidVariant
    case invalidTransactionType
    case invalidAuthenticatorType
    case invalidType(type: String)
    case faucetUrlRequired
    case failedData
    case invalidIndex
    case invalidResult
    case rpcError(error: RPCErrorValue)
}
