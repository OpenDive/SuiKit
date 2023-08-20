//
//  File.swift
//  
//
//  Created by Marcus Arnett on 7/31/23.
//

import Foundation

extension UInt64 {
    func toData() -> Data {
        var arr = [UInt8](repeating: 0, count: 8)
        for i in 0..<8 {
            arr[i] = UInt8(self >> (UInt64(i) * 8) & 0xFF)
        }
        return Data(arr)
    }
}
