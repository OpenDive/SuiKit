//
//  ObjectOwner.swift
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
import SwiftyJSON

/// `ObjectOwner` represents the possible types of ownership for objects.
public enum ObjectOwner: KeyProtocol, Equatable {
    /// Represents an object owned by an address. The associated value is a `String` containing the address.
    case addressOwner(String)

    /// Represents an object owned by another object. The associated value is a `String` containing the object's identifier.
    case objectOwner(String)

    /// Represents an object with shared ownership. The associated value is an `Int` indicating the initial shared version.
    case shared(Int)

    /// Represents an object that is immutable and cannot be owned.
    case immutable

    public static func parseGraphQL(graphql: TryGetPastObjectQuery.Data.Object.Owner) -> ObjectOwner {
        if graphql.asAddressOwner?.owner?.asObject != nil {
            return .addressOwner(graphql.asAddressOwner!.owner!.asObject!.address)
        }

        if graphql.asParent?.parent != nil {
            return .objectOwner(graphql.asParent!.parent!.address)
        }

        if graphql.asShared != nil {
            return .shared(Int(graphql.asShared!.initialSharedVersion)!)
        }

        return .immutable
    }

    public static func parseGraphQL(graphql: RPC_MOVE_OBJECT_FIELDS.Owner) -> ObjectOwner {
        if graphql.asAddressOwner != nil {
            return .addressOwner(graphql.asAddressOwner!.owner!.asAddress!.address)
        }

        if graphql.asParent != nil {
            return .objectOwner(graphql.asParent!.parent!.address)
        }

        if graphql.asShared != nil {
            return .shared(Int(graphql.asShared!.initialSharedVersion)!)
        }

        return .immutable
    }

    /// Parses a `JSON` object to produce an `ObjectOwner` object if possible.
    ///
    /// - Parameters:
    ///   - input: The JSON object representing the ownership information.
    /// - Returns: An `ObjectOwner` object if parsing is successful; otherwise returns `nil`.
    ///
    /// This method attempts to parse the provided JSON into an `ObjectOwner` by checking for
    /// various expected key-value pairs such as "AddressOwner", "ObjectOwner", and "Shared".
    public static func parseJSON(_ input: JSON) -> ObjectOwner? {
        // If the input JSON contains an address owner, process it
        if let addressOwner = input["AddressOwner"].string {
            return .addressOwner(addressOwner)
        }

        // If the input JSON contains an object owner, process it
        if let objectOwner = input["ObjectOwner"].string {
            return .objectOwner(objectOwner)
        }

        // If the input JSON contains shared ownership information, process it
        if let initialSharedVersion = input["Shared"]["initial_shared_version"].int {
            return .shared(initialSharedVersion)
        }

        // If none of the above conditions are met, return nil
        return nil
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self {
        case .addressOwner(let addressOwner):
            try Serializer.u8(serializer, 0)
            try Serializer.str(serializer, addressOwner)
        case .objectOwner(let objectOwner):
            try Serializer.u8(serializer, 1)
            try Serializer.str(serializer, objectOwner)
        case .shared(let shared):
            try Serializer.u8(serializer, 2)
            try Serializer.u64(serializer, UInt64(shared))
        case .immutable:
            try Serializer.u8(serializer, 3)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ObjectOwner {
        if let value = try? Deserializer.u8(deserializer) {
            switch value {
            case 0:
                let addressOwner: String = try Deserializer.string(deserializer)
                return .addressOwner(addressOwner)
            case 1:
                let objectOwner = try Deserializer.string(deserializer)
                return .objectOwner(objectOwner)
            case 2:
                let shared: UInt64 = try Deserializer.u64(deserializer)
                return .shared(Int(shared))
            case 3:
                return .immutable
            default:
                throw SuiError.customError(message: "Invalid object owner")
            }
        }
        return .immutable
    }
}
