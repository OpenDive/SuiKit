//
//  KeyValueProtocol.swift
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
import CryptoKit

/// Represents what type of type the key's data is going to be,
public protocol KeyValueProtocol {
    /// Get the type of data used for the key's data.
    /// - Returns: A `DataType` enum.
    func getType() -> DataType
}

/// Represents generic `Data` object.
extension Data: KeyValueProtocol {
    public func getType() -> DataType { return .data }
}

// TODO: Look into proper architecture for handling cases such as this
// TODO: where we need to represent a type that can either have a
// TODO: Data key or a P256 key.
#if swift(>=5.9)
/// Represents a `P256`public key.
extension P256.Signing.PublicKey: @retroactive Equatable {}
extension P256.Signing.PublicKey: KeyValueProtocol, @retroactive Hashable {
    public static func == (lhs: P256.Signing.PublicKey, rhs: P256.Signing.PublicKey) -> Bool {
        return lhs.rawRepresentation == rhs.rawRepresentation
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawRepresentation)
    }

    public func getType() -> DataType { return .p256 }
}

/// Represents a `P256`private key.
extension SecureEnclave.P256.Signing.PrivateKey: @retroactive Equatable {}
extension SecureEnclave.P256.Signing.PrivateKey: KeyValueProtocol, @retroactive Hashable {
    public static func == (lhs: SecureEnclave.P256.Signing.PrivateKey, rhs: SecureEnclave.P256.Signing.PrivateKey) -> Bool {
        return lhs.dataRepresentation == rhs.dataRepresentation
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }

    public func getType() -> DataType { return .p256 }
}
#else
/// Represents a `P256`public key.
extension P256.Signing.PublicKey: Equatable {}
extension P256.Signing.PublicKey: KeyValueProtocol, Hashable {
    public static func == (lhs: P256.Signing.PublicKey, rhs: P256.Signing.PublicKey) -> Bool {
        return lhs.rawRepresentation == rhs.rawRepresentation
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawRepresentation)
    }

    public func getType() -> DataType { return .p256 }
}

/// Represents a `P256`private key.
extension SecureEnclave.P256.Signing.PrivateKey: Equatable {}
extension SecureEnclave.P256.Signing.PrivateKey: KeyValueProtocol, Hashable {
    public static func == (lhs: SecureEnclave.P256.Signing.PrivateKey, rhs: SecureEnclave.P256.Signing.PrivateKey) -> Bool {
        return lhs.dataRepresentation == rhs.dataRepresentation
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }

    public func getType() -> DataType { return .p256 }
}
#endif
