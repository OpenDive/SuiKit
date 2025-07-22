//
//  JWTClaims.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Structure representing claims from a JWT token.
public struct JWTClaims {
    /// The issuer of the JWT
    public let iss: String?

    /// The subject of the JWT, typically a user ID
    public let sub: String?

    /// The audience for the JWT
    public let aud: Any?

    /// The expiration time of the JWT as a timestamp
    public let exp: TimeInterval?

    /// The time the JWT was issued as a timestamp
    public let iat: TimeInterval?

    /// Optional nonce, used in zkLogin
    public let nonce: String?

    /// Initialize with individual claim values
    public init(
        iss: String?,
        sub: String?,
        aud: Any?,
        exp: TimeInterval?,
        iat: TimeInterval?,
        nonce: String?
    ) {
        self.iss = iss
        self.sub = sub
        self.aud = aud
        self.exp = exp
        self.iat = iat
        self.nonce = nonce
    }

    /// Helper method to convert audience to string
    public func audienceString() -> String? {
        if let audString = aud as? String {
            return audString
        } else if let audArray = aud as? [String], let firstAud = audArray.first {
            return firstAud
        }
        return nil
    }

    /// Convert audience to string safely
    public func toString() -> String? {
        return audienceString()
    }
}
