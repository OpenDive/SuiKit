//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/19/23.
//

import Foundation

public struct Hex {
    public static func fromHex(hexStr: String) throws -> [UInt8] {
        let hexStr = hexStr.replacingOccurrences(of: "0x", with: "")
        
        guard let regex = try? NSRegularExpression(pattern: ".{1,2}") else {
            throw NSError(domain: "Invalid regular expression", code: 1, userInfo: nil)
        }
        
        let nsRange = NSRange(hexStr.startIndex..<hexStr.endIndex, in: hexStr)
        let matches = regex.matches(in: hexStr, options: [], range: nsRange)
        
        var intArr: [UInt8] = []
        
        for match in matches {
            let byteRange = match.range
            let byteStr = (hexStr as NSString).substring(with: byteRange)
            
            if let byte = UInt8(byteStr, radix: 16) {
                intArr.append(byte)
            } else {
                throw NSError(domain: "Unable to parse HEX: \(hexStr)", code: 2, userInfo: nil)
            }
        }
        
        return intArr
    }

    public static func toHex(bytes: [UInt8]) -> String {
        let hexBytes = bytes.map { String(format: "%02x", $0) }
        return hexBytes.joined()
    }

}
