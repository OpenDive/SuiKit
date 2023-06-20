//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation

public protocol SignerWithProviderProtocol: SignerProcotol {
    var provider: SuiProvider { get set }
    var faucetProvider: FaucetClient { get set }
    
    func getAddress() throws -> String
    func connect(provider: SuiProvider) throws -> RawSigner
    
    func requestSuiFromFaucet(_ address: String) async throws -> FaucetCoinInfo
}
