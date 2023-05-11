//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation

public struct B64 {
    public static func fromB64(sBase64: String, nBlocksSize: Int? = nil) -> [UInt8] {
        var sB64Enc = sBase64.replacingOccurrences(of: "[^A-Za-z0-9+/]", with: "", options: .regularExpression),
            nInLen = sB64Enc.count,
            nOutLen = nBlocksSize != nil
        ? Int(ceil(Double(nInLen * 3 + 1) / Double(4 * nBlocksSize!))) * nBlocksSize!
        : (nInLen * 3 + 1) >> 2,
        taBytes = [UInt8](repeating: 0, count: nOutLen)
        
        var nUint24 = 0, nOutIdx = 0, nInIdx = 0
        for character in sB64Enc {
            let nMod4 = nInIdx & 3
            nUint24 |= Int(b64ToUint6(character.asciiValue!)) << (6 * (3 - nMod4))
            if nMod4 == 3 || nInLen - nInIdx == 1 {
                for nMod3 in 0..<3 where nOutIdx < nOutLen {
                    taBytes[nOutIdx] = UInt8((nUint24 >> ((16 >> nMod3) & 24)) & 255)
                    nOutIdx += 1
                }
                nUint24 = 0
            }
            nInIdx += 1
        }
        
        return taBytes
    }
    
    public static func b64ToUint6(_ nChr: UInt8) -> UInt32 {
        switch nChr {
        case 65...90:
            return UInt32(nChr - 65)
        case 97...122:
            return UInt32(nChr - 71)
        case 48...57:
            return UInt32(nChr + 4)
        case 43:
            return 62
        case 47:
            return 63
        default:
            return 0
        }
    }
    
    public static func uint6ToB64(_ nUint6: UInt32) -> UInt8 {
      switch nUint6 {
        case 0...25:
          return UInt8(nUint6 + 65)
        case 26...51:
          return UInt8(nUint6 + 71)
        case 52...61:
          return UInt8(nUint6 - 4)
        case 62:
          return 43
        case 63:
          return 47
        default:
          return 65
      }
    }

    public static func toB64(_ aBytes: [UInt8]) -> String {
      var nMod3 = 2
      var sB64Enc = ""

      for nIdx in 0..<aBytes.count {
        nMod3 = nIdx % 3
        if nIdx > 0 && ((nIdx * 4) / 3) % 76 == 0 {
          sB64Enc += "\n"
        }
        var nUint24 = 0
        nUint24 |= Int(aBytes[nIdx]) << ((16 >> nMod3) & 24)
        if nMod3 == 2 || aBytes.count - nIdx == 1 {
          sB64Enc += String(bytes: [
            uint6ToB64(UInt32(nUint24 >> 18) & 63),
            uint6ToB64(UInt32(nUint24 >> 12) & 63),
            uint6ToB64(UInt32(nUint24 >> 6) & 63),
            uint6ToB64(UInt32(nUint24) & 63)
          ], encoding: .utf8)!
          nUint24 = 0
        }
      }

      return sB64Enc + String(repeating: nMod3 == 2 ? "=" : nMod3 == 1 ? "=" : "", count: 4 - nMod3)
    }
}
