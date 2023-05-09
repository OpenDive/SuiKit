//
//  AuthenticatorProtocol.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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

public protocol AuthenticatorProtocol: KeyProtocol {
    /// Verifies the contents of the provided data.
    ///
    /// This function takes in a Data object and attempts to verify its contents. It returns true if the data is valid and false otherwise.
    ///
    /// - Parameter data: The data to be verified.
    ///
    /// - Throws: An error of type VerificationError if the data cannot be verified.
    ///
    /// - Returns: A boolean value indicating whether or not the data is valid.
    func verify(_ data: Data) throws -> Bool

    /// Compares the current Ed25519Authenticator instance to another object conforming to AuthenticatorProtocol,
    /// and returns a boolean indicating whether they have the same publicKey and signature properties.
    ///
    /// - Parameters:
    ///    - rhs: The other object conforming to AuthenticatorProtocol to compare against.
    ///
    /// - Returns: A boolean indicating whether the two objects have the same publicKey and signature properties.
    func isEqualTo(_ rhs: any AuthenticatorProtocol) -> Bool
}
