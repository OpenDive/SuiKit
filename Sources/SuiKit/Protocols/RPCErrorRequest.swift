//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation
import AnyCodable

public protocol RPCErrorRequest {
    var method: String { get set }
    var args: [AnyCodable] { get set }
}
