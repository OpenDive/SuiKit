//
//  File.swift
//  
//
//  Created by Marcus Arnett on 6/9/23.
//

import Foundation

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
