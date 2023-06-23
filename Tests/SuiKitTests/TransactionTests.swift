//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/22/23.
//

import Foundation
import XCTest
@testable import SuiKit

final class TransactionTests: XCTestCase {
    func testThatTransferSuiWorks() async throws {
        let bobWallet = try Wallet(mnemonic: Mnemonic(
            phrase: ["crunch", "card", "stand", "mechanic", "snake", "toss", "test", "chimney", "remove", "miss", "desk", "sell"]
        ))
        let aliceWallet = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        
        print("BOBS'S ADDRESS: \(bobWallet.account.address().description)")
        
        print("BOB'S PUB KEY: \(try bobWallet.account.publicKey().description)")
        print("BOB'S PRIV KEY: \(bobWallet.account.privateKey.description)")
        
        let provider = SuiProvider(connection: devnetConnection())
//        let faucetProvider = FaucetClient(connection: devnetConnection())
        
//        let faucetResult = try await faucetProvider.funcAccount(bobWallet.account.address().description)
        
        let signer = RawSigner(wallet: bobWallet, provider: provider)
        var tx = TransactionBlock()
        let coin = try tx.splitCoin(coin: tx.gas, amounts: [tx.pure(value: .number(1000))])
        
        let _ = try tx.transferObject(objects: [coin], address: tx.pure(value: .string(aliceWallet.account.address().hex())))
        let result = try await signer.signAndExecuteTransactionBlock(&tx)
        
        print("RESULT: \(result)")
    }
}
