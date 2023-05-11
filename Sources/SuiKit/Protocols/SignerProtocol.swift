//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/9/23.
//

import Foundation

public protocol SignerProcotol {
    func getAddress() throws -> String
    func signData(data: Data) throws -> String
}
