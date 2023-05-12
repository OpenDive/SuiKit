//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation

public protocol SignerWithProvider: SignerProcotol {
    var provider: SuiProvider { get set }
    var faucetProvider: FaucetClient { get set }
    
    func getAddress() throws -> String
    func connect(provider: SuiProvider) throws -> SignerWithProvider
    
    func requestSuiFromFaucet()
}
