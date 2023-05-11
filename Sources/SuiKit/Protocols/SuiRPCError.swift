//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation

public protocol SuiRPCErrorProtocol: Error {
    var name: String { get }
    var message: String { get }
    var cause: Error? { get }
    var stack: String? { get }
}

extension SuiRPCErrorProtocol {
    public var name: String {
        return String(describing: type(of: self))
    }
    
    public var stack: String? {
        return Thread.callStackSymbols.joined(separator: "\n")
    }
}
