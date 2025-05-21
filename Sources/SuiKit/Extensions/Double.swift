//
//  File.swift
//  
//
//  Created by Marcus Arnett on 11/29/23.
//

import Foundation

extension Double {
    public func percentageToBasisPoints() throws -> Int {
        guard self >= 0 && self <= 100 else { throw SuiError.customError(message: "Invalid percentage") }
        return Int(ceil(self * 100))
    }
}
