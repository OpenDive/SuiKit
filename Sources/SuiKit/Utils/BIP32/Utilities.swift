//
//  File.swift
//  
//
//  Created by Marcus Arnett on 2/21/24.
//

import Foundation
import secp256k1

public struct Utilities {
    /// Convert the private key (32 bytes of Data) to compressed (33 bytes) or non-compressed (65 bytes) public key.
    public static func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
        guard let publicKey = SECP256K1PrivateKey.privateToPublic(privateKey: privateKey, compressed: compressed) else { return nil }
        return publicKey
    }
}
