//
//  ResolvedConstants.swift
//  SuiKit
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

public struct ResolvedConstants {
    public static let stdOptionStructName = "Option"
    public static let stdOptionModuleName = "option"
    
    public static let stdUtf8StructName = "String"
    public static let stdUtf8ModuleName = "string"
    
    public static let stdAsciiStructName = "String"
    public static let stdAsciiModuleName = "ascii"
    
    public static let suiSystemAddress = "0x3"
    public static let suiFrameworkAddress = "0x2"
    public static let moveStdlibAddress = "0x1"
    
    public static let objectModuleName = "object"
    public static let uidStructName = "UID"
    public static let idStructName = "ID"
    
    public static let suiTypeArg = "\(ResolvedConstants.suiFrameworkAddress)::sui::SUI"
    public static let validatorsEventQuery = "\(ResolvedConstants.suiSystemAddress)::validator_set::ValidatorEpochInfoEventV2"
}
