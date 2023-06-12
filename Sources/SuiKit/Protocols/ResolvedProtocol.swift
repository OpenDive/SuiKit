//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/9/23.
//

import Foundation

public protocol ResolvedProtocol {
    var address: String { get }
    var module: String { get }
    var name: String { get }
}
