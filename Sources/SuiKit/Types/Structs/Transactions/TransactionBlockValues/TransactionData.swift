//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import SwiftyJSON

public enum TransactionData: KeyProtocol {
    case V1(TransactionDataV1)
    
    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .V1(let transactionDataV1):
            try Serializer.u8(serializer, UInt8(0))
            try Serializer._struct(serializer, value: transactionDataV1)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionData {
        let type = try Deserializer.u8(deserializer)

        switch type {
        case 0:
            return TransactionData.V1(
                try Deserializer._struct(deserializer)
            )
        default:
            throw SuiError.notImplemented
        }
    }
}
