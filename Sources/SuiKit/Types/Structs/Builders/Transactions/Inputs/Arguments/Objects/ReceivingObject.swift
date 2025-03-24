//
//  ReceivingObject.swift
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

/// A structure representing a reference to an object that is either immutable or owned.
/// Conforming to `KeyProtocol` makes this struct usable wherever object keys are needed.
public struct ReceivingObject: KeyProtocol {
    /// A reference to a SuiObject.
    public var ref: SuiObjectRef

    /// Initializes a new instance of `ReceivingObject` with the provided `SuiObjectRef`.
    ///
    /// - Parameter ref: A reference to a `SuiObject`.
    public init(ref: SuiObjectRef) {
        self.ref = ref
    }

    /// Initializes a new instance of `ReceivingObject` with the provided JSON object.
    ///
    /// - Parameter input: A JSON object containing the data needed to initialize the `SuiObjectRef`.
    public init(input: JSON) {
        self.ref = SuiObjectRef(input: input)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.ref)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ReceivingObject {
        return ReceivingObject(
            ref: try Deserializer._struct(deserializer)
        )
    }
}
