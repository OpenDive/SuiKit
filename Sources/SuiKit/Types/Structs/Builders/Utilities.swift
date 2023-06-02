//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/11/23.
//

import Foundation

protocol SuperStruct {
    associatedtype Value
    func validate(value: Value) -> Value
}

func create<T: SuperStruct>(value: T.Value, structure: T) -> T.Value {
    return structure.validate(value: value)
}
