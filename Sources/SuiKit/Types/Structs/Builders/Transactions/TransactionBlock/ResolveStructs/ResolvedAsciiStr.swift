//
//  ResolvedAsciiStr.swift
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

public struct ResolvedAsciiStr: ResolvedProtocol {
    /// A string representing the address of the resolved ASCII string.
    /// By default, it is set to `ResolvedConstants.moveStdlibAddress`.
    public var address: String = ResolvedConstants.moveStdlibAddress

    /// A string representing the module of the resolved ASCII string.
    /// By default, it is set to `ResolvedConstants.stdAsciiModuleName`.
    public var module: String = ResolvedConstants.stdAsciiModuleName

    /// A string representing the name of the resolved ASCII string.
    /// By default, it is set to `ResolvedConstants.stdAsciiStructName`.
    public var name: String = ResolvedConstants.stdAsciiStructName

    /// Initializes a new instance of `ResolvedAsciiStr`.
    ///
    /// - Parameters:
    ///   - address: (Optional) A string representing the address of the resolved ASCII string.
    ///   - module: (Optional) A string representing the module of the resolved ASCII string.
    ///   - name: (Optional) A string representing the name of the resolved ASCII string.
    public init(
        address: String = ResolvedConstants.moveStdlibAddress,
        module: String = ResolvedConstants.stdAsciiModuleName,
        name: String = ResolvedConstants.stdAsciiStructName
    ) {
        self.address = address
        self.module = module
        self.name = name
    }
}
