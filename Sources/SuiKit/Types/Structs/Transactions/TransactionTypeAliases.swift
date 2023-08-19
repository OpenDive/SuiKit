//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/19/23.
//

import Foundation
import AnyCodable

public typealias EpochId = String
public typealias SequenceNumber = String
public typealias ObjectDigest = String
public typealias AuthoritySignature = String
public typealias TransactionEventDigest = String
public typealias ReturnValueType = ([UInt8], String)
public typealias TransactionEvents = [SuiEvent]
public typealias MutableReferenceOutputType = (TransactionArgument, [UInt8], String)
public typealias EmptySignInfo = [String: AnyCodable]
public typealias AuthorityName = String
