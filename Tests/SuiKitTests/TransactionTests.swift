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
//    it('create keypair from secret key', () => {
//            const secretKey = fromB64(VALID_SECRET_KEY);
//            const keypair = Ed25519Keypair.fromSecretKey(secretKey);
//            expect(keypair.getPublicKey().toBase64()).toEqual(
//                'Gy9JCW4+Xb0Pz6nAwM2S2as7IVRLNNXdSmXZi4eLmSI=',
//            );
//        });
    
    func testForBase64Validity() throws {
        let validKey = "mdqVWeFekT7pqy5T49+tV12jO0m+ESW7ki4zSU9JiCg="
        let secretKey = B64.fromB64(sBase64: validKey)
        let keypair = try ED25519PrivateKey(key: Data(secretKey)).publicKey()
        XCTAssertEqual(keypair.key.base64EncodedString(), "Gy9JCW4+Xb0Pz6nAwM2S2as7IVRLNNXdSmXZi4eLmSI=")
    }
    
    func testForDeserializingTransactionBlocks() async throws {
        let testValue = "AAMCAgpTcGxpdENvaW5zAQEAAAAAAAAAAAAB6AMAAAAAAAAAAQN1NjQBDlRyYW5zZmVyT2JqZWN0AQMAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAkIweDZmOGFlMDQ4YzdiMjI0OWNlNjlkNDYwYmEzNTg3NmE0Y2Q5OWU5YTg0OTA3NjRkNzExNjljYjhmZTBkYjcyNzAAAQdhZGRyZXNzAQAEcHVyZQHoAwAAAAAAAEA4Y2MwOGE4OTZlYjlhMTY1OTZiODk0MzljOTExZmY4ODdhYjZhZDIzOTZkNGMzZGZmN2JlMmUxMmM0Yzg3ZDc3AgRCMHg3NzMxOTBjYmZhMTlmNWM0YTdjNzBmN2I0ODE1YmE3YzdmY2Y5ZTI5ZjNmOTdiYTE1ZjdkYmMwYTdmNzc5MjliLEpDZXNURjRMVWplSjZTazlHb0VqMzUzb0dvc245Wno1ZERaVmlvNWo0aEtNBEIweGQ4YTIyMWYzYTkxZDIyYjNiYjgzYzgyODllZDZjNzIxMzEyNGRkMzRhYjJiNjJiYjBmNmI3OTA2NDYwODNhOTYsOVRvcUM3Z0tKVDlWM2VzQm9HcXBOZlNMdWlmMUgxOHROZDlkeFRWcGNjYnVAOGNjMDhhODk2ZWI5YTE2NTk2Yjg5NDM5YzkxMWZmODg3YWI2YWQyMzk2ZDRjM2RmZjdiZTJlMTJjNGM4N2Q3NwQxMDAwCzUwMDAwMDAwMDAwAQ=="
        let testData = Data.fromBase64(testValue)!
        print("DEBUG: TEST DATA - \([UInt8](testData))")
        let txData = try TransactionBlock.from(serialized: testData)
    }
    
    func testThatTransferSuiWorks() async throws {
        let privateKeyValue = B64.fromB64(sBase64: "W8hh3ioDwgAoUlm0IXRZn6ETlcLmF07DN3RQBLCQ3N0=")
        let privateKey = ED25519PrivateKey(key: Data(privateKeyValue))
        let accountAddress = try AccountAddress.fromKey(try privateKey.publicKey())
        let bobWallet = Account(accountAddress: accountAddress, privateKey: privateKey)
//        let bobWallet = try Wallet(mnemonic: Mnemonic(
//            phrase: ["crunch", "card", "stand", "mechanic", "snake", "toss", "test", "chimney", "remove", "miss", "desk", "sell"]
//        ))
        let aliceWallet = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        
//        print("BOBS'S ADDRESS: \(bobWallet.account.address().description)")
//        
//        print("BOB'S PUB KEY: \(try bobWallet.account.publicKey().description)")
//        print("BOB'S PRIV KEY: \(bobWallet.account.privateKey.description)")
        
        let provider = SuiProvider(connection: devnetConnection())
//        let faucetProvider = FaucetClient(connection: devnetConnection())

//        let faucetResult = try await faucetProvider.funcAccount(bobWallet.account.address().description)
        
//        try await Task.sleep(nanoseconds: 1_000_000_000)
        
//        let signer = RawSigner(wallet: bobWallet.account, provider: provider)
        let signer = RawSigner(wallet: bobWallet, provider: provider)
        var tx = TransactionBlock()
        let coin = try tx.splitCoin(coin: tx.gas, amounts: [tx.pure(value: .number(1000))])
        
        let _ = try tx.transferObject(objects: [coin], address: tx.pure(value: .string(aliceWallet.account.address().hex())))
        let result = try await signer.signAndExecuteTransactionBlock(&tx)
        
        print("RESULT: \(result)")
    }
}
