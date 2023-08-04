//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/22/23.
//

import Foundation
import XCTest
@testable import SuiKit

//final class TransactionTests: XCTestCase {
////    it('create keypair from secret key and mnemonics matches keytool', () => {
////            for (const t of TEST_CASES) {
////                // Keypair derived from mnemonic
////                const keypair = Ed25519Keypair.deriveKeypair(t[0]);
////                expect(keypair.getPublicKey().toSuiAddress()).toEqual(t[2]);
////
////                // Keypair derived from 32-byte secret key
////                const raw = fromB64(t[1]);
////                if (raw[0] !== 0 || raw.length !== PRIVATE_KEY_SIZE + 1) {
////                    throw new Error('invalid key');
////                }
////                const imported = Ed25519Keypair.fromSecretKey(raw.slice(1));
////                expect(imported.getPublicKey().toSuiAddress()).toEqual(t[2]);
////
////                // Exported secret key matches the 32-byte secret key.
////                const exported = imported.export();
////                expect(exported.privateKey).toEqual(toB64(raw.slice(1)));
////            }
////        });
//    let TEST_CASES = [
//        [
//            "film crazy soon outside stand loop subway crumble thrive popular green nuclear struggle pistol arm wife phrase warfare march wheat nephew ask sunny firm",
//            "AN0JMHpDum3BhrVwnkylH0/HGRHBQ/fO/8+MYOawO8j6",
//            "0xa2d14fad60c56049ecf75246a481934691214ce413e6a8ae2fe6834c173a6133",
//        ],
//        [
//            "require decline left thought grid priority false tiny gasp angle royal system attack beef setup reward aunt skill wasp tray vital bounce inflict level",
//            "AJrA997C1eVz6wYIp7bO8dpITSRBXpvg1m70/P3gusu2",
//            "0x1ada6e6f3f3e4055096f606c746690f1108fcc2ca479055cc434a3e1d3f758aa",
//        ],
//        [
//            "organ crash swim stick traffic remember army arctic mesh slice swear summer police vast chaos cradle squirrel hood useless evidence pet hub soap lake",
//            "AAEMSIQeqyz09StSwuOW4MElQcZ+4jHW4/QcWlJEf5Yk",
//            "0xe69e896ca10f5a77732769803cc2b5707f0ab9d4407afb5e4b4464b89769af14",
//        ]
//    ]
//    
//    func testForBase64Validity() throws {
//        let validKey = "mdqVWeFekT7pqy5T49+tV12jO0m+ESW7ki4zSU9JiCg="
//        let secretKey = Data.fromBase64(validKey)!
//        let keypair = try ED25519PrivateKey(key: Data(secretKey)).publicKey()
//        XCTAssertEqual(keypair.key.base64EncodedString(), "Gy9JCW4+Xb0Pz6nAwM2S2as7IVRLNNXdSmXZi4eLmSI=")
//    }
//    
//    func testThatKeypairSecretKeyAndMnemonicMatches() throws {
//        for test in TEST_CASES {
//            let wallet = try Wallet(phrase: test[0].components(separatedBy: " "))
//            XCTAssertEqual(try wallet.account.accountAddress.toSuiAddress(), test[2])
//        }
//    }
//    
//    func testForDeserializingTransactionBlocks() async throws {
//        let testValue = "AEA4Y2MwOGE4OTZlYjlhMTY1OTZiODk0MzljOTExZmY4ODdhYjZhZDIzOTZkNGMzZGZmN2JlMmUxMmM0Yzg3ZDc3AQEAQDhjYzA4YTg5NmViOWExNjU5NmI4OTQzOWM5MTFmZjg4N2FiNmFkMjM5NmQ0YzNkZmY3YmUyZTEyYzRjODdkNzcEMTAwMAs1MDAwMDAwMDAwMAMCAgpTcGxpdENvaW5zAQEAAAAAAAAAAAAB6AMAAAAAAAAAAQN1NjQBDlRyYW5zZmVyT2JqZWN0AQMAAAAAAAEAAAAAAAAAAkIweGMzYWYwZDM4YWU1MjViNWM2NWFmOTdhYmViODU5ZmJmYmYwMzlmMTMwMTQxZGQzNWQ3NTVmOWM5ZDJmMGY3YjAAAQdhZGRyZXNzAQAEcHVyZQHoAwAAAAAAAA=="
//        let testData = Data.fromBase64(testValue)!
//        print("DEBUG: TEST DATA - \([UInt8](testData))")
//        let txData = try TransactionBlock.from(serialized: testData)
//    }
//    
//    func testThatTransferSuiWorks() async throws {
//        let privateKeyValue = Data.fromBase64("W8hh3ioDwgAoUlm0IXRZn6ETlcLmF07DN3RQBLCQ3N0=")!
//        let privateKey = ED25519PrivateKey(key: privateKeyValue)
//        let accountAddress = try AccountAddress(address: try privateKey.publicKey().key)
//        let bobWallet = Account(accountAddress: accountAddress, privateKey: privateKey)
//        
//        let provider = SuiProvider(connection: devnetConnection())
////        let faucetProvider = FaucetClient(connection: devnetConnection())
////
////        let faucetResult = try await faucetProvider.funcAccount(bobWallet.address().description)
////        
////        try await Task.sleep(nanoseconds: 1_000_000_000)
//
//        let signer = RawSigner(wallet: bobWallet, provider: provider)
//        var tx = TransactionBlock()
//        let coin = try tx.splitCoin(coin: tx.gas, amounts: [tx.pure(value: .number(1000))])
//        
//        print("DEBUG: BOB WALLET SUI ADDRESS - \(try bobWallet.address().toSuiAddress())")
//        
//        let _ = try tx.transferObject(objects: [coin], address: try bobWallet.address().toSuiAddress())
//        let result = try await signer.signAndExecuteTransactionBlock(&tx)
//        
//        print("RESULT: \(result)")
//    }
//}
