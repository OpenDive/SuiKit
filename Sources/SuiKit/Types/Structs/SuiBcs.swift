//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/15/23.
//

import Foundation

public enum CallArg: Codable {
    case pure(PureCallArg)
    case object(ObjectArg)
}
