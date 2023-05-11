//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/10/23.
//

import Foundation

class RPCError: Error {
    let req: RPCErrorRequest
    let code: Any?
    let data: Any?
    let cause: Error?

    init(options: (req: RPCErrorRequest, code: Any?, data: Any?, cause: Error?)) {
        self.req = options.req
        self.code = options.code
        self.data = options.data
        self.cause = options.cause
    }
}

class RPCValidationError: Error {
    let req: RPCErrorRequest
    let result: Any?
    let cause: Error?

    init(options: (req: RPCErrorRequest, result: Any?, cause: Error?)) {
        self.req = options.req
        self.result = options.result
        self.cause = options.cause
    }

    func toString() -> String {
        var str = "RPC Validation Error: The response returned from RPC server does not match the Swift definition. This is likely because the SDK version is not compatible with the RPC server."
        
        if let cause = cause {
            str += "\nCause: \(cause)"
        }
        
        if let result = result {
            str += "\nResponse Received: \(String(describing: result))"
        }
        
        return str
    }
}

class FaucetRateLimitError: Error {}
