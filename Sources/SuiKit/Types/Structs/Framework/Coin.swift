//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/9/23.
//

import Foundation

public struct Coin {
    public static let suiSystemAddress = "0x3"
    public static let suiFrameworkAddress = "0x2"
    public static let moveStandardLibraryAddress = "0x1"
    public static let objectModuleName = "object"
    public static let uidStructName = "UID"
    public static let idStructName = "ID"
    public static let suiTypeArg = "0x2::sui::SUI"
    public static let validatorsEventQuery = "0x3::validator_set::ValidatorEpochInfoEventV2"

    public static let suiClockObjectId = normalizeSuiAddress(value: "0x6")

    public static let payModuleName = "pay"
    public static let paySplitCoinVecFuncName = "split_vec"
    public static let payJoinCoinFuncName = "join"
    public static let coinTypeArgRegex = "/^0x2::coin::Coin<(.+)>$/"

    public static func isCoin(data: SuiObjectResponse) -> Bool {
        guard let type = data.type else { return false }

        let regex = try! NSRegularExpression(pattern: Coin.coinTypeArgRegex)
        let range = NSRange(location: 0, length: type.utf16.count)
        let match = regex.firstMatch(in: type, options: [], range: range)

        return match != nil
    }

    public static func isSUI(data: SuiObjectResponse) -> Bool {
        guard let type = data.type else { return false }
        return Coin.getCoinSymbol(coinTypeArg: type) == "SUI"
    }

    public static func getCoinSymbol(coinTypeArg: String) -> String {
        if let range = coinTypeArg.range(of: ":", options: .backwards) {
            return String(coinTypeArg[range.upperBound...])
        }
        return coinTypeArg
    }

    public static func getCoinStructTag(coinTypeArg: String) -> SuiMoveNormalizedStructType {
        return SuiMoveNormalizedStructType(
            address: normalizeSuiAddress(value: coinTypeArg.components(separatedBy: "::").first ?? ""),
            module: coinTypeArg.components(separatedBy: "::").dropFirst().first ?? "",
            name: coinTypeArg.components(separatedBy: "::").dropFirst(2).first ?? "",
            typeArguments: []
        )
    }

    public static func totalBalance(coins: [CoinStruct]) -> Int {
        return coins.reduce(0) { partialResult, coinStruct in
            partialResult + (Int(coinStruct.balance) ?? 0)
        }
    }

    public static func sortByBalance(coins: [CoinStruct]) -> [CoinStruct] {
        return coins.sorted { a, b in
            (Int(a.balance) ?? 0) < (Int(b.balance) ?? 0)
        }
    }
}
