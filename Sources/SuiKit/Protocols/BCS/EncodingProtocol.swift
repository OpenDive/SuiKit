//
//  EncodingProtocol.swift
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
import UInt256
@preconcurrency import AnyCodable

public protocol EncodingProtocol: EncodingContainer { }

extension UInt8: EncodingProtocol { }
extension UInt16: EncodingProtocol { }
extension UInt32: EncodingProtocol { }
extension UInt64: EncodingProtocol { }
extension UInt128: EncodingProtocol { }
extension UInt256: EncodingProtocol { }
extension Int: EncodingProtocol { }
extension UInt: EncodingProtocol { }

extension Bool: EncodingProtocol { }
extension String: EncodingProtocol { }
extension Data: EncodingProtocol { }
extension String.UTF8View: EncodingProtocol { }

extension Array: EncodingContainer where Element: EncodingProtocol { }
extension Dictionary: EncodingContainer where Key: EncodingProtocol, Value: Any { }
