//
//  watchOS_ExampleApp.swift
//  watchOS_Example
//
//  Created by Marcus Arnett on 1/23/25.
//

import SwiftUI

@main
struct watchOS_ExampleApp: App {
    @State var viewModel: HomeViewModel

    init() {
        do {
            let userDefaults = UserDefaults.standard
            var defaultWalletSeeds: [[String]] = []
            
            for element in userDefaults.dictionaryRepresentation() {
                let mnemo = userDefaults.object(forKey: element.key) as? [String]
                
                if let mnemo, mnemo.count == 12 {
                    defaultWalletSeeds.append(mnemo)
                }
            }
            
            if defaultWalletSeeds.isEmpty {
                self.viewModel = try HomeViewModel()
                userDefaults.set(
                    self.viewModel.currentWallet.mnemonic.mnemonic(),
                    forKey: try self.viewModel.currentWallet.accounts[0].address()
                )
            } else {
                self.viewModel = try HomeViewModel(defaultWalletSeeds)
            }
        } catch {
            print(error)
            fatalError()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: self.viewModel)
        }
    }
}
