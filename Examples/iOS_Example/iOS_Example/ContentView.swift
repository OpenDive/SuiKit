//
//  ContentView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 5/1/23.
//

import SwiftUI
import SuiKit

struct ContentView: View {
    @State private var alice: Wallet?
    @State private var bob: Wallet?
    
    @State private var isAirdropping: Bool = false
    
    var body: some View {
        VStack {
            Image("suiLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 200)
                .padding(.horizontal)
                .padding(.top, 25)
            
            if let bob, let alice {
                Text("Bob's wallet address: \(bob.account.accountAddress.description)")
                    .padding(.bottom)
                Text("Alice's wallet address: \(alice.account.accountAddress.description)")
            }
            
            Button {
                do {
                    let bobMnemo = try Mnemonic(phrase:
                        "tank math hero giraffe hen various song praise much december direct search".components(separatedBy: " ")
                    )
                    let aliceMnemo = Mnemonic(wordcount: 12, wordlist: Wordlists.english)
                    
                    self.alice = try Wallet(mnemonic: aliceMnemo)
                    self.bob = try Wallet(mnemonic: bobMnemo)
                    
                    if let bob, let alice {
                        print("Bob's wallet address: \(bob.account.accountAddress.description)")
                        print("Alice's wallet address: \(alice.account.accountAddress.description)")
                    }
                } catch {
                    print(error)
                }
            } label: {
                Text("Create Wallets")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            
            Button {
                Task {
                    do {
                        if let bob, let alice {
                            self.isAirdropping = true
                            let faucetClient = FaucetClient(baseUrl: "https://faucet.devnet.sui.io/gas")
//                            try await faucetClient.funcAccount(alice.account.accountAddress.description)
                            try await faucetClient.funcAccount(bob.account.accountAddress.description)
                            self.isAirdropping = false
                        }
                    } catch {
                        print(error)
                    }
                }
            } label: {
                if isAirdropping {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Airdrop 10 SUI")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
            
            Button {
                Task {
                    do {
                        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: "https://sui-devnet-kr-1.cosmostation.io"))
                        let gas = try await restClient.getGasPrice()
                        if let bob, let alice {
                            let txBlock = try await restClient.transferSui(
                                bob.account, alice.account.accountAddress, Int(gas), UInt64(1_000_000_000), "0x2::coin::Coin<0x2::sui::SUI>"
                            )
                            let result = try await restClient.executeTransactionBlocks(txBlock, bob.account)
                            print(result)
                        }
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Transfer 1 SUI from Bob to Alice")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
