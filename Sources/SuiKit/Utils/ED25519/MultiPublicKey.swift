//
//  MultiPublicKey.swift
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

/// The ED25519 Multi-Public Key
public struct MultiPublicKey: EncodingProtocol, CustomStringConvertible, Equatable {
    /// The Public Keys themselves
    public var keys: [ED25519PublicKey]

    /// The current amount of keys in the keys array
    public var threshold: Int

    /// The minimum amount of keys to initialize this class
    public static let minKeys: Int = 2

    /// The maximum amount of keys allowed for initialization
    public static let maxKeys: Int = 32

    /// The minimum threshold amount
    public static let minThreshold: Int = 1

    init(keys: [ED25519PublicKey], threshold: Int, checked: Bool = true) throws {
        if checked {
            if MultiPublicKey.minKeys > keys.count || MultiPublicKey.maxKeys < keys.count {
                throw AccountError.keysCountOutOfRange(min: MultiPublicKey.minKeys, max: MultiPublicKey.maxKeys)
            }
            if MultiPublicKey.minThreshold > threshold || threshold > keys.count {
                throw AccountError.thresholdOutOfRange(min: MultiPublicKey.minThreshold, max: keys.count)
            }
        }

        self.keys = keys
        self.threshold = threshold
    }

    public var description: String {
        return "\(self.threshold)-of-\(self.keys.count) Multi-Ed25519 public key"
    }

    /// Serialize the threshold and concatenated keys of a given threshold signature scheme instance to a Data object.
    ///
    /// This function concatenates the keys of the instance and serializes the threshold and concatenated keys to a Data object.
    ///
    /// - Returns: A Data object containing the serialized threshold and concatenated keys.
    public func toBytes() -> Data {
        var concatenatedKeys: Data = Data()
        for key in self.keys {
            concatenatedKeys += key.key
        }
        return concatenatedKeys + Data([UInt8(self.threshold)])
    }

    /// Deserialize a Data object to a MultiPublicKey instance.
    ///
    /// This function deserializes the given Data object to a MultiPublicKey instance by extracting the threshold and keys from it.
    ///
    /// - Parameters:
    ///    - key: A Data object containing the serialized threshold and keys of a MultiPublicKey instance.
    ///
    /// - Returns: A MultiPublicKey instance initialized with the deserialized keys and threshold.
    ///
    /// - Throws: An SuiError object indicating that the given Data object is invalid or cannot be deserialized to a MultiPublicKey instance.
    public static func fromBytes(_ key: Data) throws -> MultiPublicKey {
        let minKeys = MultiPublicKey.minKeys
        let maxKeys = MultiPublicKey.maxKeys
        let minThreshold = MultiPublicKey.minThreshold

        let nSigners = Int(key.count / ED25519PublicKey.LENGTH)

        if minKeys > nSigners || nSigners > maxKeys {
            throw AccountError.keysCountOutOfRange(min: minKeys, max: maxKeys)
        }

        guard let keyThreshold = key.last else {
            throw AccountError.noContentInKey
        }

        let threshold = Int(keyThreshold)

        if minThreshold > threshold || threshold > nSigners {
            throw AccountError.thresholdOutOfRange(min: minThreshold, max: nSigners)
        }

        var keys: [ED25519PublicKey] = []

        for i in 0..<nSigners {
            let startByte = i * ED25519PublicKey.LENGTH
            let endByte = (i + 1) * ED25519PublicKey.LENGTH
            keys.append(try ED25519PublicKey(data: Data(key[startByte..<endByte])))
        }

        return try MultiPublicKey(keys: keys, threshold: threshold)
    }

    /// Serializes an output instance using the given Serializer.
    ///
    /// - Parameter serializer: The Serializer instance used to serialize the data.
    ///
    /// - Throws: An error if the serialization fails.
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.toBytes())
    }
}
