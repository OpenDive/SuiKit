//
//  ResolvedProtocol.swift
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

/// Protocol defining the requirements for a resolved object.
/// Conforming types are expected to contain all necessary data for
/// uniquely identifying a resource, typically within a blockchain or
/// other decentralized architecture.
public protocol ResolvedProtocol: Equatable {
    /// The address that uniquely identifies the location of the resource.
    /// This could be a blockchain address, IP address, or other identifier.
    var address: String { get }

    /// The module to which the resource belongs. This gives additional
    /// context to the resource's nature and how it should be handled.
    var module: String { get }

    /// The human-readable name of the resource. This serves as an easier
    /// way to refer to the resource, though it may not be unique.
    var name: String { get }
}
